module NonaNats

using Nona.Games
using Nona.Games.Niancat

export NatsPublisher, NatsEvent
export GameService
export subject, eventtype
export
    receive!,
    NewGameEvent,
    GuessEvent,
    InstanceId

#
# NATS
#

struct InstanceId
    value::String
end

abstract type NatsEvent end
subject(ev::NatsEvent) = ev.subject
eventtype(ev::NatsEvent) = @error("Implement eventtype(::$(typeof(ev)))")

abstract type NatsPublisher end

publish!(p::NatsPublisher, ev::NatsEvent) = @error("Implement publish!(::$(typeof(p)), ::$(typeof(ev)))")

#
# Events published to NATS
#
struct CorrectEvent <: NatsEvent
    subject::String
    player::Player
    guess::Guess
end

eventtype(::CorrectEvent) = "correct"

struct IncorrectEvent <: NatsEvent
    subject::String
    player::Player
    guess::Guess
end

eventtype(::IncorrectEvent) = "incorrect"

#
# Error and log events
#

struct ErrorEvent <: NatsEvent
    subject::String
    message::String

    ErrorEvent(message::String) = new("service.nona.log", message)
end

eventtype(::ErrorEvent) = "error"

#
# Niancat specific interfaces
#
struct NatsNiancatPublisher <: Publisher{NiancatGame}
    natspub::NatsPublisher
    instanceid::InstanceId
end

instancesubject(instanceid::InstanceId) = "game.niancat.instance.$(instanceid)"

function Games.publish!(publisher::NatsNiancatPublisher, ev::Niancat.Correct)
    subject = instancesubject(publisher.instanceid)
    publish!(publisher.natspub, CorrectEvent(subject, ev.player, ev.guess))
end
function Games.publish!(publisher::NatsNiancatPublisher, ev::Niancat.Incorrect)
    subject = instancesubject(publisher.instanceid)
    publish!(publisher.natspub, IncorrectEvent(subject, ev.player, ev.guess))
end
Games.publish!(publisher::NatsNiancatPublisher, ev::Games.Response) = @error("Yo")

#
# Game service
#
Base.show(io::IO, instanceid::InstanceId) = print(io, instanceid.value)

struct NewGameEvent
    puzzle::String
    instanceid::InstanceId
end

struct GuessEvent
    player::Player
    word::String
    instanceid::InstanceId
end

struct NoSuchGameInstanceError <: Exception end

struct GameInstances
    instances::Dict{InstanceId, NiancatGame}
    dictionary::Dictionary

    GameInstances(dictionary::Dictionary) = new(Dict{InstanceId, NiancatGame}(), dictionary)
end

function new!(gi::GameInstances, publisher::NatsPublisher, instanceid::InstanceId, puzzle::String)
    niancatpublisher = NatsNiancatPublisher(publisher, instanceid)
    game = NiancatGame(Word(puzzle), niancatpublisher, gi.dictionary)
    gi.instances[instanceid] = game
end

function find(gi::GameInstances, instanceid::InstanceId) :: Game
    try
        gi.instances[instanceid]
    catch
        throw(NoSuchGameInstanceError())
    end
end

struct GameService
    publisher::NatsPublisher
    instances::GameInstances

    GameService(pub::NatsPublisher, dictionary::Dictionary) = new(pub, GameInstances(dictionary))
end

function receive!(service::GameService, guess::GuessEvent)
    try
        game = find(service.instances, guess.instanceid)
        gameaction!(game, guess.player, Guess(Word(guess.word)))
    catch ex
        if isa(ex, NoSuchGameInstanceError)
            publish!(service.publisher, ErrorEvent("Unknown service \"$(guess.instanceid.value)\""))
        else
            rethrow()
        end
    end
end

function receive!(service::GameService, newgame::NewGameEvent)
    new!(service.instances, service.publisher, newgame.instanceid, newgame.puzzle)
end
receive!(::GameService, ev) = nothing

end # module NonaNats

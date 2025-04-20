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
# Niancat specific interfaces
#
struct NatsNiancatPublisher <: Publisher{NiancatGame} end

#
# NATS
#

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
# Game service
#
struct InstanceId
    value::String
end

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

function new!(gi::GameInstances, instanceid::InstanceId, puzzle::String)
    niancatpublisher = NatsNiancatPublisher()
    game = NiancatGame(Word(puzzle), niancatpublisher, gi.dictionary)
    gi.instances[instanceid] = game
end

function find(gi::GameInstances, instanceid::InstanceId)
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
        _gameinstance = find(service.instances, guess.instanceid)
        subject = "game.niancat.instance.$(guess.instanceid)"
        publish!(service.publisher,
            CorrectEvent(subject, guess.player, Guess(Word("PUSSGURKA"))))
    catch ex
        if isa(ex, NoSuchGameInstanceError)
            publish!(service.publisher, ErrorEvent("Unknown service \"$(guess.instanceid.value)\""))
        else
            rethrow()
        end
    end
end

function receive!(service::GameService, newgame::NewGameEvent)
    new!(service.instances, newgame.instanceid, newgame.puzzle)
end
receive!(::GameService, ev) = nothing

end # module NonaNats

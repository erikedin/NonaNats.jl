module NonaNats

using Nona.Games

export NatsPublisher, NatsEvent
export GameService
export subject, eventtype
export
    receive!,
    NewGameEvent,
    GuessEvent

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
# Game service
#
struct NewGameEvent
    NewGameEvent(args...) = new()
end

struct GuessEvent
    player::Player

    GuessEvent(player, args...) = new(player)
end


struct GameService
    publisher::NatsPublisher
    dictionary::Dictionary
end

function receive!(service::GameService, guess::GuessEvent)
    publish!(service.publisher,
        CorrectEvent("game.niancat.instance.cafe", guess.player, Guess(Word("PUSSGURKA"))))
end
receive!(::GameService, ev) = nothing

end # module NonaNats

module NonaNats

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
end

eventtype(::CorrectEvent) = "correct"

#
# Game service
#
struct NewGameEvent
    NewGameEvent(args...) = new()
end

struct GuessEvent
    GuessEvent(args...) = new()
end


struct GameService
    publisher::NatsPublisher
end

receive!(::GameService, ev) = nothing

end # module NonaNats

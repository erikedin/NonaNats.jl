# MIT License
#
# Copyright (c) 2025 Erik Edin
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

using Behavior
using Nona.Games
using NonaNats

#
# Nona mocks
#

struct SetDictionary <: Dictionary
    words::Set{Word}

    SetDictionary(words::AbstractVector{String}) = new(Set{Word}(Word[Word(s) for s in words]))
end

Base.iterate(sd::SetDictionary) = iterate(sd.words)
Base.iterate(sd::SetDictionary, state) = iterate(sd.words, state)
Base.length(sd::SetDictionary) = length(sd.words)
Base.in(word::Word, sd::SetDictionary) = word in sd.words

#
# NonaNats mocks
#

struct MockPublisher <: NatsPublisher
    events

    MockPublisher() = new([])
end

NonaNats.publish!(p::MockPublisher, ev::NatsEvent) = push!(p.events, ev)

function uniqueevent(publisher::MockPublisher, subj::String, evtype::String)
    matchingevents = [
        ev
        for ev in publisher.events
        if subject(ev) == subj && eventtype(ev) == evtype
    ]
    only(matchingevents)
end

# Reads a table with two columns as a key/value table,
# and produces a Dict from it.
function associativetable(context)
    keyvalues = [
        (row[1], row[2])
        for row in context.datatable
    ]
    Dict{String, String}(keyvalues)
end

@given("a dictionary") do context
    # Each row in context.datatables is an array of words,
    # but there is only one word in each array.
    dictionary = [
        words[1]
        for words in context.datatable
    ]
    context[:dictionary] = SetDictionary(dictionary)
end

@given("a Niancat game service") do context
    dictionary = context[:dictionary]

    publisher = MockPublisher()
    service = GameService(publisher, dictionary)

    context[:service] = service
    context[:publisher] = publisher
end

@given("a new Niancat instance with puzzle \"{String}\" and id \"{String}\"") do context, puzzle, instanceid
    service = context[:service]
    newgame = NewGameEvent(puzzle, instanceid)
    receive!(service, newgame)
end

@when("the player {String} guesses PUSSGURKA in instance \"{String}\"") do context, playername, instanceid
    service = context[:service]
    players = context[:players]
    alice = players[playername]

    guess = GuessEvent(alice, "PUSSGURKA", instanceid)
    receive!(service, guess)
end

@then("a Correct event is published with") do context
    publisher = context[:publisher]

    fields = associativetable(context)
    subject = fields["subject"]

    event = uniqueevent(publisher, subject, "correct")

    @expect event.player.name == fields["player"]
    @expect event.guess == Guess(fields["word"])
end

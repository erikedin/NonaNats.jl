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

using Test
using NonaNats
using Nona.Games.Niancat
using Nona.Games

struct NamedPlayer <: Player
    name::String
end

struct MockPublisher <: NatsPublisher
    events
end

function uniqueevent(publisher::MockPublisher, subj::String, evtype::String)
    matchingevents = [
        ev
        for ev in publisher.events
        if subject(ev) == subj && eventtype(ev) == evtype
    ]
    only(matchingevents)
end

@testset "Guessing" begin

@testset "Guess; Puzzle is UPSSGURKA; Guess PUSSGURKA is correct" begin
    # Arrange
    alice = NamedPlayer("Alice")
    publisher = MockPublisher()
    service = GameService(publisher)

    # Create the game instance expected by the guess
    newgame = NewGameEvent("UPSSGURKA", "cafe")
    receive!(service, newgame)

    # Act
    guess = GuessEvent(alice, "PUSSGURKA", "cafe")
    receive!(service, guess)

    # Assert
    response = uniqueevent(publisher, "game.niancat.instance.cafe", "guess")
    @test response.player == alice
    @test response.guess == Guess(Word("PUSSGURKA"))
end

end
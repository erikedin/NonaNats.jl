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

Feature: Guessing words in Niancat

    Background: A dictionary
        Given a dictionary
            | DATORSPEL |
            | LEDARPOST |
            | PUSSGURKA |
            | ORDPUSSEL |
          And a Niancat game service

    Scenario: Guess correctly
        Given a new Niancat instance with puzzle "PUSSGURKA" and id "cafe"
         When the player Alice guesses PUSSGURKA in instance "cafe"
         Then a Correct event is published with
            | subject | game.niancat.instance.cafe |
            | player  | Alice                      |
            | word    | PUSSGURKA                  |

    Scenario: Guess correctly with different instance id
        Given a new Niancat instance with puzzle "PUSSGURKA" and id "babe"
         When the player Alice guesses PUSSGURKA in instance "babe"
         Then a Correct event is published with
            | subject | game.niancat.instance.babe |
            | player  | Alice                      |
            | word    | PUSSGURKA                  |

    Scenario: Guess incorrectly
        Given a new Niancat instance with puzzle "ORDPUSSEL" and id "cafe"
         When the player Alice guesses PUSSGURKA in instance "cafe"
         Then an Incorrect event is published with
            | subject | game.niancat.instance.cafe |
            | player  | Alice                      |
            | word    | PUSSGURKA                  |
          And there is no "correct" events in "game.niancat.instance.cafe"
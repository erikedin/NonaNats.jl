# NonaNats.jl
A NATS interface for Nona.jl, for use with KonsulatetGames.

# Events
This service listens to these events from the KonsulatetGames NATS server:

| Subject                    | Event type | Reason                                                   |
|----------------------------|------------|----------------------------------------------------------|
| game.niancat               | newgame    | Create a new instance of `Nona.Game.Niancat.NiancatGame` |
| game.niancat               | endgame    | Release the instance of `Nona.Game.Niancat.NiancatGame`  |
| game.niancat.instance.<id> | guess      | Provide a guess to the `NiancatGame` instance            |



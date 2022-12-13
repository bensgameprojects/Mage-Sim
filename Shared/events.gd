extends Node

## Signal emitted when the player places a thing, passing the object and its
## position in map coordinates
signal thing_placed(thing, cellv)

## Signal emitted when the player removes a thing, passing the object and its
## position in map coordinates
signal thing_removed(thing, cellv)

# Signal emitted when the simulation triggers the systems for updates
signal systems_ticked(delta)

extends Node

## Signal emitted when the player places an object, passing the object and its
## position in map coordinates
signal object_placed(object, cellv)

## Signal emitted when the player removes an object, passing the object and its
## position in map coordinates
signal object_removed(object, cellv)

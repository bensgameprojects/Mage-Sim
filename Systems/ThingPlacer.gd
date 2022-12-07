extends TileMap


## Distance from the player when the mouse stops being able to interacty
const MAXIMUM_WORK_DISTANCE := 275.0

## When using `world_to_map()` or `map_to_world()`, `TileMap` reports values from the
## top-left corner of the tile.
## We might need an offset of like 16,16 or something but for now im going to
## leave it at 0,0
const POSITION_OFFSET := Vector2(0,0)

## Temporary variable to hold the active blueprint.
## For testing purposes, we hold it here until we build the inventory.
var _blueprint: BlueprintThing

## The simulation's thing tracker. We use its functions to know if a cell is available or it
## already has an thing.
var _thing_tracker: ThingTracker

## The ground tiles. We can check the position we're trying to put an thing down on
## to see if the mouse is over the tilemap.
var _ground: TileMap

## The player thing. We can use it to check the distance from the mouse to prevent
## the player from interacting with things that are too far away.
var _player: KinematicBody2D

## Temporary variable to store references to things and blueprint scenes.
## We split it in two: blueprints keyed by their names and things keyed by
## their blueprints.
onready var Library := {
	"AetherConverter": preload("res://Things/AetherConverterThing.tscn").instance(),
}


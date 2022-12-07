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
	"AetherConverter": preload("res://Things/Blueprints/AetherConverterBlueprint.tscn").instance(),
}

func _ready() -> void:
	# Use the existing blueprint to act as a key for the thing scene, so we can instance
	# things given their blueprint
	Library[Library.AetherConverter] = preload("res://Things/Things/AetherConverterThing.tscn")

## Since we are temporarilty instancing blueprints for the library u ntil we have
## set up a UI or something, clean up blueprints when object leaves the tree
func _exit_tree() -> void:
	Library.AetherConverter.queue_free()

## Setup function sets the placer up with the data that it needs to function
## and adds any preplaced things to the tracker
func setup(tracker: ThingTracker, ground: TileMap, player: KinematicBody2D) -> void:
	# Use the function to initialize our private references
	# this makes refactoring easier because the ThingPlacer doesn't need
	# hard-coded paths to the ThingTracker, Groundtiles, and Player nodes
	_thing_tracker = tracker
	_ground = ground
	_player = player
	
	# for each child of thingPlacer, if it extended Thing, add it to the tracker
	# and ensure its position snaps to the grid
	for child in get_children():
		if child is Thing:
			# Get the world position of the child into map coordinates. These are
			# integer coordinates, which makes them ideal for repeatable
			# Dictionary keys, instead of the more rounding-error prone
			# decimal numbers of world coordinates.
			var map_position := world_to_map(child.global_position)
			
			# Report the Thing to the tracker to add it to the dictionary
			_thing_tracker.place_thing(child, map_position)

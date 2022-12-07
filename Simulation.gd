extends Node

# This node will keep track of the simulation
# For the buildings that need to use it
# This node is the only member of the Simulation group

var _thing_tracker := ThingTracker.new() 

# this needs to be set by the SceneSwitcher
var _ground
var _thing_placer
var _player

# Called when the node enters the scene tree for the first time.
func _ready():
	# NOTE: the tutorial says to set the entity_placer setup here
	# but since we are using the scene switcher for scene setup
	# we can make the call there
	pass # Replace with function body.

func set_thing_placer(thing_placer) -> void:
	_thing_placer = thing_placer

# called by scene switcher to set the _ground tiles for us
func set_ground_tiles(ground_tiles) -> void:
	_ground = ground_tiles

func set_player(player) -> void:
	_player = player

# used by SceneSwitcher to set up the entity placer
func get_tracker() -> ThingTracker:
	return _thing_tracker

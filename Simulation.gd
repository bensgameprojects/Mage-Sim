extends Node

# This node will keep track of the simulation
# For the buildings that need to use it
# This node is the only member of the Simulation group

var _thing_tracker := ThingTracker.new() 

# this needs to be set by the SceneSwitcher
var _ground

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# called by scene switcher to set the _ground tiles for us
func set_ground_tiles(ground_tiles):
	_ground = ground_tiles


extends Node

# This node will keep track of the simulation
# For the buildings that need to use it
# This node is the only member of the Simulation group
# update 30 times per second by default
export var simulation_speed := 1.0 / 30.0

onready var simulation_timer = $SimulationTimer

var _thing_tracker: ThingTracker

# this needs to be set by the SceneSwitcher
var _scene_name : String
var _ground : TileMap
var _thing_placer : TileMap
var _player : Player
var _flat_things : YSort
var _power_system : PowerSystem
var _work_system : WorkSystem
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# NOTE: the tutorial says to set the entity_placer setup here
	# but since we are using the scene switcher for scene setup
	# we can make the call there
	# simulation_timer.start(simulation_speed)
	pass

func set_thing_placer(thing_placer) -> void:
	_thing_placer = thing_placer

# called by scene switcher to set the _ground tiles for us
func set_ground_tiles(ground_tiles) -> void:
	_ground = ground_tiles

func set_player(player) -> void:
	_player = player

func set_flat_things(flat_things) -> void:
	_flat_things = flat_things

func set_scene_name(scene_name) -> void:
	_scene_name = scene_name
	
func set_thing_tracker(thing_tracker) -> void:
	_thing_tracker = thing_tracker
# used by SceneSwitcher to set up the entity placer
func get_tracker() -> ThingTracker:
	return _thing_tracker



func setup(
	scene_name: String, thing_tracker: ThingTracker, power_system : PowerSystem, work_system : WorkSystem, ground_tiles, thing_placer, flat_things, player
	) -> void:
	_scene_name = scene_name
	_thing_tracker = thing_tracker
	
	_ground = ground_tiles
	_thing_placer = thing_placer
	_flat_things = flat_things
	_player = player
	# This will need to be redone so we can save the state of the things,
	# then disconnect signal and clean up. but for now it works.
	if _power_system != null:
		_power_system.disconnect_signals()
		_power_system.queue_free()
	if _work_system != null:
		_work_system.queue_free()
	_power_system = power_system
	_work_system = work_system
	simulation_timer.start(simulation_speed)

func _on_SimulationTimer_timeout():
	Events.emit_signal("systems_ticked", simulation_speed)

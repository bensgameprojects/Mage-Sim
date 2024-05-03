extends Node2D

onready var playerCamera = $PlayerCamera
onready var spawnHandler = $SpawnHandler
# we get the lowest ground layer as a reference for the simulation system
# to place objects in the world that snap to the grid. therefore groundlayer1
# needs to INCLUDE ALL of the relevant collision information for the level
onready var _ground = $Buildmap
onready var _thing_placer = $SpawnHandler/ThingPlacer
onready var _flat_things = $FlatThings
var _scene_name


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass

func add_player(player_instance):
	spawnHandler.add_player(player_instance)
	player_instance.attach_camera(playerCamera.get_path())
	
func remove_player() -> Player:
	var player_instance = spawnHandler.remove_player()
	player_instance.detach_camera()
	return player_instance
	
func get_ground_tiles():
	return _ground

func get_thing_placer():
	return _thing_placer

func get_flat_things():
	return _flat_things

func setup_thing_placer(scene_name, tracker, ground, flat_things, player) -> void:
	# give the world script a copy of the scene name just so it has it for later
	_scene_name = scene_name
	_thing_placer.setup(scene_name, tracker, ground, flat_things, player)

# Scene switcher will call this function so the world can 
# have things loaded in it.
func load_things(thing_save_dict: Dictionary):
	_thing_placer.load_state(thing_save_dict)

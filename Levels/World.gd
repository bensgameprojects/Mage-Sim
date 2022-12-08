extends Node2D

onready var playerCamera = $PlayerCamera
onready var spawnHandler = $SpawnHandler
# we get the lowest ground layer as a reference for the simulation system
# to place objects in the world that snap to the grid. therefore groundlayer1
# needs to INCLUDE ALL of the relevant collision information for the level
onready var _ground = $GroundLayer1
onready var _thing_placer = $SpawnHandler/ThingPlacer
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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

func setup_thing_placer(tracker, ground, player) -> void:
	_thing_placer.setup(tracker, ground, player)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

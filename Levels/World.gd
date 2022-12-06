extends Node2D

onready var playerCamera = $PlayerCamera
onready var spawnHandler = $SpawnHandler
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
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

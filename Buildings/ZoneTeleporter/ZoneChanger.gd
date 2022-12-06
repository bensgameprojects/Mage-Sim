extends Node2D

signal change_level

export(String) var destination_scene
onready var teleportWait = $TeleportWait
onready var baseSprite = $BaseSprite
# Called when the node enters the scene tree for the first time.
func _ready():
	baseSprite.playing = true
	connect("change_level", get_tree().get_nodes_in_group("SceneSwitcher")[0], "_on_SceneSwitcher_change_level")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# if a body enters then we start the timer
func _on_ZoneChanger_body_entered(body):
	# check if the body is player
	if(body.name == "Player"):
	# if so, start timer (will start with set wait_time in inspector)
		teleportWait.start()

func _on_ZoneChanger_body_exited(body):
	# check if the body is player
	if(body.name == "Player"):
	# if so, stop timer
		teleportWait.stop()

# if the timer times out then we change zones
func _on_TeleportWait_timeout():
	# emit level changed
	emit_signal("change_level", destination_scene)


extends Node2D

export(String) var destination_scene_name = "Home"
onready var teleportWait = $TeleportWait
onready var baseSprite = $BaseSprite
# Called when the node enters the scene tree for the first time.
func _ready():
	baseSprite.playing = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_destination(scene_name: String) -> void:
	destination_scene_name = scene_name

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
	# if you decide where levels go you can build the path here
	# and make destination_scene the name of the scene instead
	Events.emit_signal("change_level", destination_scene_name)


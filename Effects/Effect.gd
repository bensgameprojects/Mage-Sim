extends AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	# connecting object we're connecting to and function we're connecting to
	# to animation_finished
	connect("animation_finished", self, "_on_animation_finished")
	play("Animate")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_animation_finished():
	queue_free()

extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func create_grass_effect():
	# load the grass effect scene (packed scene)
	var GrassEffect = load("res://Effects/GrassEffect.tscn")
	# instantiate the node (unpack scene)
	var grassEffect = GrassEffect.instance()
	# add effect to current scene
	var world = get_tree().current_scene
	world.add_child(grassEffect)
	# put grass effect global position to the grass position
	grassEffect.global_position = global_position

func _on_Hurtbox_area_entered(_area):
	create_grass_effect()
	queue_free()

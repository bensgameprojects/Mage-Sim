extends StaticBody2D
# load the grass effect scene (packed scene)
const GrassEffect = preload("res://Effects/GrassEffect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func create_grass_effect():
	# instantiate the node (unpack scene)
	var grassEffect = GrassEffect.instance()
	# add effect to current scene
#	var world = get_tree().current_scene
#	world.add_child(grassEffect)
	# equivalently just do this to ge tthe world scene
	get_parent().add_child(grassEffect)
	# put grass effect global position to the grass position
	grassEffect.global_position = global_position

func _on_Hurtbox_area_entered(area):
	# SeekArea is used for homing projectiles so exclude it
	if area.name != "SeekArea":
		create_grass_effect()
		queue_free()

extends Area2D

export(int) var COLLISION_STRENGTH = 30
# detect whether touching and then get a push vector
# to keep things from stacking exactly on top
var overlapping_areas = Array()

func is_colliding():
	# get array of all overlapping areas
	overlapping_areas = get_overlapping_areas()
	return overlapping_areas.size() > 0

func get_push_vector():
	var push_vector = Vector2.ZERO
	if overlapping_areas:
		# just going to care about the first thing we collide with
		# this check will happen often enough that it will eventually
		# push away until there are no more areas overlapping
		
		# direction_to returns a normalized vector already
		push_vector = overlapping_areas[0].global_position.direction_to(global_position)
	return push_vector

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

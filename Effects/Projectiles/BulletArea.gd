extends Area2D

var knockback_vector
var damage
var response

# Called when the node enters the scene tree for the first time.
func _ready():
	monitoring = true

#hit confirmation behavior
func hit_confirm(entity) -> bool:
	response = get_parent().on_hit_confirmed(entity)
	return response

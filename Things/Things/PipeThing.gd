class_name PipeThing
extends Thing


onready var sprite := $Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
# Save the state of the pipe.
# The pipe uses the sprites region_rect as a selector for the possible
# directions. this is all setup when the pipe is placed by the blueprint.
# So to save the pipe's state we just need to save the region rect.
# We also need to save the thing_id so that the thing placer knows what
# type of thing to place when it loads.
# The system will handle the rest.
func save() -> Dictionary:
	# use the parent save function to get the parent class vars
	var save_dict = .save()
	# save the thing_id
	save_dict["thing_id"] = "Pipe"
	# get the sprite region which is the direction of the pipe
	save_dict["region_rect"] = sprite.region_rect
	return save_dict


func load_state(save_dict) -> bool:
	# use the parent func to laod the Thing stuff
	if not .load_state(save_dict):
		return false
	if save_dict.has_all(["thing_id", "region_rect"]) and save_dict["thing_id"] == "Pipe":
		sprite.region_rect = save_dict["region_rect"]
		return true
	return false

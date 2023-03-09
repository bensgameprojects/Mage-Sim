extends Thing


onready var power := $PowerSource
onready var animation_player := $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	# for now just play the one
	# but it will be configured depending on the type
	animation_player.play("generate_air_power")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_info() -> String:
	return "%.1f E/s" % power.get_effective_power()

func save() -> Dictionary:
	var save_dict = .save()
	save_dict["thing_id"] = "AetherConverter"
	save_dict["power_source"] = power.save()
	return save_dict

func load_state(save_dict : Dictionary) -> bool:
	if not .load_state(save_dict):
		return false
	if save_dict.has_all(["thing_id", "power_source"]) and save_dict["thing_id"] == "AetherConverter":
		return power.load_state(save_dict["power_source"])
	return false

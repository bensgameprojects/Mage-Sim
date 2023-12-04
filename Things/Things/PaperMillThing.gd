extends Thing

"""
The paper mill takes up to 2 inputs and creates an output based on a recipe supplied to it.
"""

onready var work = $WorkComponent
onready var output_inventory = $OutputInventoryGrid
onready var input_inventory = $InputInventoryGrid
onready var animated_sprite = $AnimatedSprite
onready var power_receiver = $PowerReceiver
# Called when the node enters the scene tree for the first time.
func _ready():
	work.work_speed = 1.0
	work.output_inventory = output_inventory
	work.input_inventory = input_inventory
	work.connect_signals()

func get_info() -> String:
	if work.is_enabled:
		return (
			"Making: %s\nTime left: %ss"
			% [
				work.current_output["name"],
				stepify(work.available_work, 0.1)
			]
		)
	else:
		return (
			"Idle"
		)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# the BuildingConfig UI will call this function and send the selected
# recipe. it will always be a recipe that this building can use.
func change_recipe(recipe: Dictionary):
	work.setup_work(recipe)


func _on_WorkComponent_work_accomplished(amount):
	Events.emit_signal("info_updated", self)


func _on_WorkComponent_work_done(current_recipe : Dictionary):
	if work.deduct_cost(current_recipe):
		# returns true meaning we successfully consumed the items.
		var remainder = output_inventory.add_or_merge(current_recipe["product_item_id"], current_recipe["amount_produced"])
		if remainder > 0:
			work.can_produce_recipe = false
	# We made the item or failed somehow, so setup work again. and check requirements for production.
	work.setup_work(work.current_recipe)


func _on_WorkComponent_work_enabled_changed(enabled : bool) -> void:
	# Set animation state here
	if enabled:
		animated_sprite.playing = true
	else:
		animated_sprite.playing = false

func save() -> Dictionary:
	var save_dict = .save()
	save_dict["thing_id"] = "PaperMill"
	save_dict["power_receiver"] = power_receiver.save()
	save_dict["work"] = work.save()
	save_dict["input_inventory"] = input_inventory.serialize()
	save_dict["output_inventory"] = output_inventory.serialize()
	return save_dict

func load_state(save_dict: Dictionary) -> bool:
	if save_dict.has_all(["thing_id", "power_receiver", "work", "input_inventory", "output_inventory"]) and save_dict["thing_id"] == "PaperMill":
		var success = power_receiver.load_state(save_dict["power_receiver"])
		success = success and input_inventory.deserialize(save_dict["input_inventory"])
		success = success and output_inventory.deserialize(save_dict["output_inventory"])
		success = success and work.load_state(save_dict["work"])
		return success
	return false

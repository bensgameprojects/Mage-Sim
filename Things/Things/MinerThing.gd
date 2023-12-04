extends Thing


onready var work = $WorkComponent
onready var output_inventory = $OutputInventoryGrid

# Called when the node enters the scene tree for the first time.
func _ready():
	work.work_speed = 1.0
	work.output_inventory = output_inventory
	work.connect_signals()

func get_info() -> String:
	if work.is_enabled:
		return (
			"Mining for: %s\nTime left: %ss"
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


func _on_WorkComponent_work_accomplished(_amount):
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
	# Set Farm animation state here
	if enabled:
		$Sprite.modulate = Color.red
	else:
		$Sprite.modulate = Color.white

func save() -> Dictionary:
	var save_dict = .save()
	save_dict["thing_id"] = "Miner"
	save_dict["work"] = work.save()
	save_dict["output_inventory"] = output_inventory.serialize()
	return save_dict

func load_state(save_dict: Dictionary) -> bool:
	if save_dict.has_all(["thing_id", "work", "output_inventory"]) and save_dict["thing_id"] == "Miner":
		var success = output_inventory.deserialize(save_dict["output_inventory"])
		success = success and work.load_state(save_dict["work"])
		return success
	return false

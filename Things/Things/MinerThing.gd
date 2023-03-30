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
	# Farm output_inventory is size (1,1)
	# Get the item if there is one
	var item = output_inventory.get_item_at(Vector2(0,0))
	# No item, so add the recipe product.
	if item == null:
		output_inventory.create_and_add_item_amount(current_recipe["product_item_id"], current_recipe["amount_produced"])
	# There is an item see if it matches and is stackable to add to the current stack
	elif item is InventoryItem and item.prototype_id == current_recipe["product_item_id"] and item.get_property("is_stackable"):
		var current_amount = item.get_property("stack_size")
		var max_stack_size = item.get_property("max_stack_size")
		if current_amount < max_stack_size:
			current_amount = min(max_stack_size, current_amount + current_recipe["amount_produced"])
			item.set_property("stack_size", current_amount)
			output_inventory.emit_signal("contents_changed")
		if current_amount == max_stack_size:
			# The output inventory is full, setting this to false will halt the system
			work.can_produce_recipe = false
	# We made the item now setup work again.
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

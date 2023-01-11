extends Thing

"""
The smelter takes 2 inputs and creates an output based on a recipe supplied to it.
"""

onready var work = $WorkComponent
onready var output_inventory = $OutputInventoryGrid
onready var input_inventory = $InputInventoryGrid
onready var sprite = $Sprite

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
	# We made the item or failed somehow, so setup work again. and check requirements for production.
	work.setup_work(work.current_recipe)


func _on_WorkComponent_work_enabled_changed(enabled : bool) -> void:
	# Set Farm animation state here
	if enabled:
		sprite.modulate = Color.red
	else:
		sprite.modulate = Color.white

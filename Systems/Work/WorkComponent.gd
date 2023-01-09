# A component that makes Things craft items over time.
class_name WorkComponent
extends Node

# Emitted when some amount of work has been accomplished
signal work_accomplished(amount)

# Emitted when all the work has been accomplished
signal work_done(output)

# Emitted when something causes the worker to stop working
signal work_enabled_changed(enabled)

# The recipe we are currently using to do the automated crafting with.
var current_recipe: Dictionary

# Metadata for the expected item.
var current_output : Dictionary

# How much work time is available to complete in seconds
var available_work := 0.0

# How fast the machine is working. A value of 1.0 means 100% speed
var work_speed := 0.0

# If 'true' the worker satisfies the requirements for the recipe:
# The worker can afford the recipe with materials in the input_inventory
var can_afford_recipe := false setget _set_can_afford_recipe

# If 'true' the worker has enough space to produce an item in the output_inventory
var can_produce_recipe := false setget _set_can_produce_recipe

# If 'true' the worker should do work when the simulation ticks the work system
var is_enabled := false setget _set_is_enabled

# The inventory for input items for the building
var input_inventory = null

# The inventory for output items
var output_inventory = null

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

func setup_work(recipe: Dictionary):
	"""
	Here is an example of the recipe dictionary that will be passed to the machine
	when it is configured.
	{
		"id":"lumber",
		"name":"Lumber",
		"producing_thing":"Farm",
		"componentIDs":[],
		"componentAmts":[],
		"product_item_id":"Lumber",
		"amount_produced":1,
		"base_craft_time":1
	},
	"""
	# Set the current_recipe if it's different then get the new current_output
	if recipe != current_recipe:
		current_recipe = recipe
		current_output = ItemsList.get_item_data_by_id(recipe["product_item_id"])
	available_work = recipe["base_craft_time"]
	can_afford_recipe = check_afford_recipe(recipe)
	can_produce_recipe = check_produce_recipe(recipe)
	if can_afford_recipe and can_produce_recipe:
		is_enabled = true

func work(delta: float) -> void:
	if is_enabled and can_afford_recipe and can_produce_recipe and available_work > 0.0:
		var work_done := delta * work_speed
		available_work -= work_done
		emit_signal("work_accomplished", work_done)
		if available_work <= 0.0:
			emit_signal("work_done", current_recipe)

# Checks if the output inventory is full or not
# Assumes that all items will be 1x1 (should be fine)
func is_output_inventory_full() -> bool:
	if output_inventory.get_item_count() == output_inventory.size.x * output_inventory.size.y:
		return true
	return false

func _set_is_enabled(value: bool) -> void:
	if is_enabled != value:
		emit_signal("work_enabled_changed", value)
	is_enabled = value

func _set_can_produce_recipe(value: bool) -> void:
	if can_produce_recipe != value:
		can_produce_recipe = value
		if value == false:
			# the value was true and now it is false
			# so we must turn off the machine
			is_enabled = false

func _set_can_afford_recipe(value: bool) -> void:
	if can_afford_recipe != value:
		can_afford_recipe = value
		if value == false:
			# the value was true and now it is false
			# so we must turn off the machine
			is_enabled = false

# Returns true or false if recipe can be afforded
# If there is no input_inventory then it returns true
# If the recipe is null then it returns false
func check_afford_recipe(recipe: Dictionary) -> bool:
	if not recipe.empty() and input_inventory != null:
		return input_inventory.can_afford_recipe(recipe["componentIDs"], recipe["componentAmts"])
	elif recipe ==  null or recipe.empty():
		return false
	return true

func deduct_cost(recipe: Dictionary) -> bool:
	if not recipe.empty() and input_inventory != null:
		return input_inventory.deduct_cost(recipe["componentIDs"], recipe["componentAmts"])
	else: # the recipe was empty or no input inventory so we deducted nothing from nothing.
		return true

# Returns true or false if making a product would fit in the output_inventory
# If the output_inventory or the recipe is null then it returns false.
func check_produce_recipe(recipe: Dictionary) -> bool:
	if recipe != null and output_inventory != null:
		# the inventory is full but it does have the item so check if we have space in the stacks
		if(is_output_inventory_full() and output_inventory.has_item_by_id(current_output["id"]) and current_output["is_stackable"]):
			var items = output_inventory.get_all_items_by_id(current_output["id"])
			var max_stack_size = current_output["max_stack_size"]
			var amount_produced = recipe["amount_produced"]
			for item in items:
				var stack_size = item.get_property("stack_size")
				var available_space = max_stack_size - stack_size
				if available_space >= amount_produced:
					return true
				else:
					# reduce the debt by whatever we can (or zero)
					amount_produced -= available_space
			if amount_produced != 0:
				# We were unable to find enough space/stacks for the output so we cannot produce the recipe
				return false
		# the inventory is full but it does not have the item (no matching stacks)
		elif is_output_inventory_full():
			return false
		# the inventory is not full and it does not have the item
		else:
			return true
	# If recipe is null or output_inventory is null then we cannot produce the item
	return false

# These functions should be connected by the parent thing's script
# For the WorkComponent to check the status of the work when the Thing's
# input and output inventories are modified by the player or the Thing itself.
func _input_inventory_contents_changed() -> void:
	can_afford_recipe = check_afford_recipe(current_recipe)

func _output_inventory_contents_changed() -> void:
	can_produce_recipe = check_produce_recipe(current_recipe)

# Connect the signals to the input and output inventories if set
func connect_signals() -> void:
	if input_inventory != null:
		input_inventory.connect("contents_changed", self, "_input_inventory_contents_changed")
	if output_inventory != null:
		output_inventory.connect("contents_changed", self, "_output_inventory_contents_changed")

# Disconnect the signals to the input and output inventories if set
func disconnect_signals() -> void:
	if input_inventory != null:
		input_inventory.disconnect("contents_changed", self, "_input_inventory_contents_changed")
	if output_inventory != null:
		output_inventory.disconnect("contents_changed", self, "_output_inventory_contents_changed")

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

# The expected item that should result from this crafting job.
var current_output : InventoryItem

# How much work time is available to complete in seconds
var available_work := 0.0

# How fast the machine is working. A value of 1.0 means 100% speed
var work_speed := 0.0

# If 'true' the worker should do work when the simulation ticks the work system
var is_enabled := false setget _set_is_enabled

# The inventory for input items for the building
var input_inventory: InventoryGrid

# The inventory for output items
var output_inventory: InventoryGrid

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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
	# Set the current_recipe
	current_recipe = recipe
	# Use product_item_id to create a new InventoryItem
	# this will be the dummy item for reference
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _set_is_enabled(value: bool) -> void:
	if is_enabled != value:
		emit_signal("work_enabled_changed", value)
	is_enabled = value

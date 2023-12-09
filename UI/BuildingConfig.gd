extends Control

# Onready vars for Status stuff
onready var title_label = $Status/MarginContainer/VBoxContainer/TitleLabel
onready var recipe_item_list = $Recipes/RecipeItem
onready var product_texture_rect = $Status/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/ProductTextureRect
onready var product_item_name_label = $Status/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/ProductItemName
onready var work_progress_bar = $Status/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/WorkProgressBar
onready var input_inventory_label = $Status/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/InputinventoryLabel
onready var input_inventory_ctrl = $Status/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/CenterContainer2/InputInventoryCtrl
onready var output_inventory_label = $Status/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/OutputInventoryLabel
onready var output_inventory_ctrl = $Status/MarginContainer/VBoxContainer/CenterContainer/VBoxContainer/CenterContainer/OutputInventoryCtrl
onready var worker_panel = $Status

# Onready vars for RecipePanel stuff
onready var recipe_info_panel = $Recipes
onready var recipe_name = $Recipes/MarginContainer/VBoxContainer/RecipeName
onready var recipe_requirements = $Recipes/MarginContainer/VBoxContainer/RecipeRequirements
onready var recipe_product_item_texture_rect = $Recipes/MarginContainer/VBoxContainer/ProductItemTexture
onready var assign_recipe_button = $Recipes/MarginContainer/VBoxContainer/MakeRecipeButton
# Other variables for keeping track
var current_thing : Thing
const title_string = "Building Config"
var current_recipe_info_recipe : Dictionary
var thing_assigned_recipe : Dictionary
var thing_expected_output : Dictionary
# an array containing recipe_id strings indexed by the position
# of the item in the recipe_item_list
var recipe_list_index = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("player_facing_thing", self, "_on_player_facing_thing")
#	Events.connect("info_updated", self, "_on_info_updated")
	hide()
	clear_recipe_panel()
	input_inventory_label.hide()
	output_inventory_label.hide()

func _unhandled_input(event):
	if event.is_action_pressed("building_config"):
		Events.emit_signal("get_player_facing_thing")
		# only show if there is some thing to configure
		if not self.visible and current_thing:
			# get the current thing we're looking at
			
			_set_info(current_thing)
			show()
			# Hide the recipe panel on open.
#			recipe_info_panel.hide()
		else:
			_clear_info(current_thing)
			hide()
	elif event.is_action_pressed("ui_cancel"):
		if self.visible:
			hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# only update the thing if the config is NOT open.
func _on_player_facing_thing(thing: Thing) -> void:
	if(current_thing != thing and not self.visible):
		_clear_info(current_thing)
		current_thing = thing

# only update the display if the config is OPEN
# use a separate _update_info function instead of _set_info
func _on_info_updated(thing: Thing) -> void:
	if(current_thing and current_thing == thing and self.visible):
		_set_info(current_thing)

# The initial setup of a thing and connections
func _set_info(thing: Thing) -> void:
	# Check if thing is a worker or a power_source
	# since each will be handled differently.
	if thing.is_in_group(Types.WORKERS):
		_set_worker_info(thing)
	elif thing.is_in_group(Types.POWER_SOURCES):
		_set_power_info(thing)


func _set_worker_info(thing: Thing):
	# get the thing's id
	var thing_id = BuildingList.get_thing_name_from(thing)
	# Get the thing_info related to the thing
	var building_info = BuildingList.get_building_by_id(thing_id)
	# set the title of the window to include selected building name
	title_label.text = building_info["name"] + " " + title_string
	# Get the list of recipes this building can make
	var recipes = RecipeList.get_all_recipes_for_thing(thing_id)
	# Add the recipes to the recipe item list
	for recipe in recipes:
		recipe_item_list.add_item(recipe["name"])
		# Add the recipe id's to the list index in the same order they are listed
		recipe_list_index.append(recipe["id"])
	# Get the state of the building, current recipe, progress, etc.
	var work_component = get_work_component(thing)
	# Display the information
	# Set the input and output item slots with info from building_state
	if work_component.input_inventory is InventoryGrid:
		input_inventory_ctrl.inventory = work_component.input_inventory
		input_inventory_ctrl.show()
		input_inventory_label.show()
	if work_component.output_inventory is InventoryGrid:
		output_inventory_ctrl.inventory = work_component.output_inventory
		output_inventory_ctrl.show()
		output_inventory_label.show()
	# Connect to the signals
	connect_work_signals(work_component)
	# This should get the rest of recipe window stuff that we need set up
	_update_thing(thing)
	if not thing_assigned_recipe.empty():
		set_recipe_panel(thing_assigned_recipe)

# Updates the display to the current information for the thing
# If it's a worker, then it gets the current recipe and fills the fields
func _update_thing(thing: Thing) -> void:
	if thing.is_in_group(Types.WORKERS):
		var work_component = get_work_component(thing)
		thing_assigned_recipe = work_component.current_recipe
		thing_expected_output = work_component.current_output
		if not thing_assigned_recipe.empty():
			# Set the work progress bar if there's a recipe
			# for some reason the work_done signal is happening at 90% progress
			# despite the timing being correct. this little scaling hack will make it count to 100%
			work_progress_bar.max_value = work_component.current_recipe["base_craft_time"]*0.9
			work_progress_bar.value = work_progress_bar.max_value - work_component.available_work
			#print("max " + str(work_progress_bar.max_value) + " available " + str(work_component.available_work))
		else:
			work_progress_bar.max_value = 1.0
			work_progress_bar.value = 0.0
		# Set the recipes product item info: name and texture
		if not thing_expected_output.empty():
			product_item_name_label.text = thing_expected_output["name"]
			product_texture_rect.texture = load(thing_expected_output["image"])
			#product_texture_rect.rect_scale = output_inventory_ctrl.field_dimensions / product_texture_rect.rect_size
		else:
			product_item_name_label.text = "No recipe set!"
		#worker_panel.set_deferred("rect_size", Vector2.ZERO)

func _set_power_info(thing: Thing):
	# This will show some data about the power system
	# That the thing contributes to.
	pass

# Clear the config so its ready to be set
func _clear_info(thing: Thing) -> void:
	if thing is Thing and current_thing.is_in_group(Types.WORKERS):
		input_inventory_ctrl.hide()
		input_inventory_ctrl.inventory = null
		input_inventory_label.hide()
		output_inventory_label.hide()
		output_inventory_ctrl.hide()
		output_inventory_ctrl.inventory = null
		product_texture_rect.texture = null
		product_item_name_label.text = ""
		title_label.text = title_string
		work_progress_bar.value = work_progress_bar.min_value
		disconnect_work_signals(get_work_component(thing))
		clear_recipe_panel()

func set_recipe_panel(recipe: Dictionary):
	current_recipe_info_recipe = recipe
	recipe_name.text = recipe["name"]
	recipe_product_item_texture_rect.texture = load(ItemsList.get_item_data_by_id(recipe["product_item_id"])["image"])
	#recipe_product_item_texture_rect.rect_size = Vector2(16,16)
	#recipe_product_item_texture_rect.set_deferred("rect_scale", output_inventory_ctrl.field_dimensions / recipe_product_item_texture_rect.rect_size)
	recipe_requirements.text = build_requirements_string(recipe)
	if thing_assigned_recipe == recipe:
		assign_recipe_button.disabled = true
		recipe_name.text += " (Assigned)"
	else:
		assign_recipe_button.disabled = false
	assign_recipe_button.show()

func clear_recipe_panel():
	recipe_item_list.clear()
	recipe_list_index.clear()
	recipe_product_item_texture_rect.texture = null
	recipe_name.text = ""
	recipe_requirements.text = ""
	product_texture_rect.texture = null
	assign_recipe_button.hide()

func get_work_component(thing: Thing) -> WorkComponent:
	for child in thing.get_children():
		if child is WorkComponent:
			return child
	return null

func connect_work_signals(work_component: WorkComponent) -> void:
	if not work_component.is_connected("work_accomplished", self, "_on_work_accomplished"):
		work_component.connect("work_accomplished", self, "_on_work_accomplished")
	if not work_component.is_connected("work_done", self, "_on_work_done"):
		work_component.connect("work_done", self, "_on_work_done")

func disconnect_work_signals(work_component: WorkComponent) -> void:
	if work_component.is_connected("work_accomplished", self, "_on_work_accomplished"):
		work_component.disconnect("work_accomplished", self, "_on_work_accomplished")
	if work_component.is_connected("work_done", self, "_on_work_done"):
		work_component.disconnect("work_done", self, "_on_work_done")

func _on_work_accomplished(work_done) -> void:
	work_progress_bar.value += work_done
	#print("value " + str(work_progress_bar.value) + " work_done " + str(work_done))

# Reset the work progress bar the inventory should auto update when the item is added 
func _on_work_done(_current_output) -> void:
	work_progress_bar.value = work_progress_bar.min_value



func build_requirements_string(recipe: Dictionary) -> String:
	var requirements_string = "Requirements:\n"
	var num_components = recipe["component_ids"].size()
	if num_components == 0:
		requirements_string += "None."
	else: # at least 1 item
		for i in range(num_components):
			var item_data = ItemsList.get_item_data_by_id(recipe["component_ids"][i])
			# Add the item name and amount
			requirements_string += str(recipe["component_amts"][i]) + " " + item_data["name"]
			if recipe["component_amts"][i] > 1:
				# pluralize
				requirements_string += "s"
			# if we still have more requirements to append, add a comma
			if i < num_components - 1:
				requirements_string += "\n"
	return requirements_string

# this should tell the current_thing to setup the work for this recipe
func _on_MakeRecipeButton_pressed():
	if current_thing is Thing and current_thing.has_method("change_recipe"):
		assign_recipe_button.disabled = true
		recipe_name.text += " (Assigned)"
		current_thing.change_recipe(current_recipe_info_recipe)
		_update_thing(current_thing)


func _on_RecipeItem_item_selected(index):
	var recipe_id = recipe_list_index[index]
	# Show the RecipeInfo panel and fill
	set_recipe_panel(RecipeList.get_recipe_by_id(recipe_id))


func _on_RecipeItem_nothing_selected():
	recipe_item_list.unselect_all()
	if thing_assigned_recipe != null and not thing_assigned_recipe.empty():
		set_recipe_panel(thing_assigned_recipe)
	else:
		current_recipe_info_recipe = {}
		recipe_product_item_texture_rect.texture = null
		recipe_name.text = ""
		recipe_requirements.text = ""
		product_texture_rect.texture = null
		assign_recipe_button.hide()

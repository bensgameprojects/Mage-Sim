extends Control


onready var title_label = $Panel/MarginContainer/VBoxContainer/TitleLabel
onready var recipe_item_list = $Panel/MarginContainer/VBoxContainer/HSplitContainer/RecipeHBox/RecipeItemList
onready var product_texture_rect = $Panel/MarginContainer/VBoxContainer/HSplitContainer/CenterContainer/VBoxContainer/ProductItemInfo/ProductTextureRect
onready var product_item_name_label = $Panel/MarginContainer/VBoxContainer/HSplitContainer/CenterContainer/VBoxContainer/ProductItemInfo/ProductItemName
onready var work_progress_bar = $Panel/MarginContainer/VBoxContainer/HSplitContainer/CenterContainer/VBoxContainer/WorkProgressBar
onready var input_item_1 = $Panel/MarginContainer/VBoxContainer/HSplitContainer/CenterContainer/VBoxContainer/RecipeComponents/InputCtrlItemSlot1
onready var input_item_2 = $Panel/MarginContainer/VBoxContainer/HSplitContainer/CenterContainer/VBoxContainer/RecipeComponents/InputCtrlItemSlot2
onready var input_item_3 = $Panel/MarginContainer/VBoxContainer/HSplitContainer/CenterContainer/VBoxContainer/RecipeComponents/InputCtrlItemSlot3

var current_thing : Thing
const title_string = "Building Config"
# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("player_facing_thing", self, "_on_player_facing_thing")
	Events.connect("info_updated", self, "_on_info_updated")
	hide()

func _gui_input(event):
	if event.is_action_pressed("building_config"):
		# only show if there is some thing to configure
		if not self.visible and current_thing:
			show()
		else:
			hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# only update the thing if the config is NOT open.
func _on_player_facing_thing(thing: Thing) -> void:
	if(current_thing != thing and not self.visible):
		current_thing = thing
		if not thing:
			_clear_info()
		else:
			_set_info(current_thing)

# only update the display if the config is OPEN
func _on_info_updated(thing: Thing) -> void:
	if(current_thing and current_thing == thing and self.visible):
		_set_info(current_thing)

func _set_info(thing: Thing) -> void:
	# get the thing's id
	var thing_id = BuildingList.get_thing_name_from(thing)
	# Get the thing_info related to the thing
	var building_info = BuildingList.get_building_by_id(thing_id)
	# set the title of the window to include selected building name
	title_label.text = building_info["name"] + title_string
	# Get the list of recipes this building can make
	var recipes = RecipeList.get_recipes_for_building(thing_id)
	# Add the recipes to the recipe item list
	for recipe in recipes:
		recipe_item_list.add_item(recipe["name"])
	# Get the state of the building, current recipe, progress, etc.
	var building_state = thing.get_thing_state()
	# Display the information
	# Set the input and output item slots with info from building_state
	# Set the current recipe as the selected recipe in the recipe list
	# Set the work progress bar
	# Set the recipes product item info: name and texture
# Clear the config so its ready to be set
func _clear_info() -> void:
	pass

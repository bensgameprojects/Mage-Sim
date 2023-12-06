extends Control
"""
 All building icons must be named their buildingid followed by Icon.png
 and placed inside the icon_path folder.
"""
var icon_path = "res://Things/Assets/Icons/"
onready var building_select_list = $BuildingSelectList
onready var building_name_label = $BuildingInfoVBoxContainer/HBoxContainer/BuildingName
onready var building_category_label = $BuildingInfoVBoxContainer/BuildingCategory
onready var building_description_label = $BuildingInfoVBoxContainer/BuildingDescription
onready var building_icon_rect = $BuildingInfoVBoxContainer/HBoxContainer/Icon
onready var building_requirements_label = $BuildingInfoVBoxContainer/BuildingRequirements
# An array of building_ids corresponding to the order they are listed in the
# BuildingSelectList
var building_list_index = []
# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	var unlocked_buildings = BuildingList.get_unlocked_buildings()
	for building in unlocked_buildings:
		building_select_list.add_item(building["name"])
		# add to the building list index in the same order we add the items
		building_list_index.append(building["id"])
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _gui_input(event):
	if event.is_action_pressed("ui_cancel") and self.visible:
		self.visible = false

func _on_BuildMenuToggle_pressed():
	self.visible = not self.visible

func _on_BuildingSelectList_item_activated(index):
	var selected_building = building_list_index[index]
	# close the menu and tell thing placer to use the blueprint
	self.visible = false
	Events.emit_signal("place_blueprint", selected_building)


func _on_BuildingSelectList_item_selected(index):
	var building_id = building_list_index[index]
	var building_info = BuildingList.get_building_by_id(building_id)
	populate_building_info(building_info)

func populate_building_info(building_info):
	building_name_label.text = building_info["name"]
	building_category_label.text = "Category: " + building_info["category"]
	building_description_label.text = building_info["description"]
	building_icon_rect.set_texture(load_icon(building_info["id"]))
	building_requirements_label.text = build_requirements_string(building_info)

func build_requirements_string(building_info) -> String:
	var requirements_string = "Requirements to Build:\n"
	var num_components = building_info["component_ids"].size()
	if num_components == 0:
		requirements_string += "None."
	else: # at least 1 item
		for i in range(num_components):
			var item_data = ItemsList.get_item_data_by_id(building_info["component_ids"][i])
			# Add the item name and amount
			requirements_string += str(building_info["component_amts"][i]) + " " + item_data["name"]
			if building_info["component_amts"][i] > 1:
				# pluralize
				requirements_string += "s"
			# if we still have more requirements to append, add a comma
			if i < num_components - 1:
				requirements_string += "\n"
	return requirements_string
# For now just make sure all icons are 32 x 32 so they are the same size 
# in the build menu.
func load_icon(building_id):
	var texture = load(icon_path + building_id + "Icon.png")
	return texture

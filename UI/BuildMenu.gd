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
# A dictionary that uses the name of the building as the key and the value is 
# the id. Basically a helper to get the id of a building from its name in the
# building_select_list
var buildingNameToID = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	var unlocked_buildings = BuildingList.get_unlocked_buildings()
	for building in unlocked_buildings:
		building_select_list.add_item(building["name"])
		buildingNameToID[building["name"]] = building["id"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and self.visible:
		self.visible = false

func _on_BuildMenuToggle_pressed():
	self.visible = not self.visible

func _on_BuildingSelectList_item_activated(index):
	var selected_building = building_select_list.get_item_text(index)
	# close the menu and tell thing placer to use the blueprint
	self.visible = false
	Events.emit_signal("place_blueprint", buildingNameToID[selected_building])


func _on_BuildingSelectList_item_selected(index):
	var selected_building = building_select_list.get_item_text(index)
	var building_id = buildingNameToID[selected_building]
	var building_info = BuildingList.get_building_by_id(building_id)
	populate_building_info(building_info)

func populate_building_info(building_info):
	building_name_label.text = building_info["name"]
	building_category_label.text = "Category: " + building_info["category"]
	building_description_label.text = building_info["description"]
	building_icon_rect.set_texture(load_icon(building_info["id"]))


# For now just make sure all icons are 32 x 32 so they are the same size 
# in the build menu.
func load_icon(building_id):
	var texture = load(icon_path + building_id + "Icon.png")
	return texture

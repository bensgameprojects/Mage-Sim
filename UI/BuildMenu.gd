extends Control

onready var building_list = $BuildingList

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false
	var unlocked_buildings = BuildingList.get_unlocked_buildings()
	print(unlocked_buildings)
	for building in unlocked_buildings:
		building_list.add_item(building["name"])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and self.visible:
		self.visible = false

func _on_BuildingList_item_activated(index):
	var selected_building = building_list.get_item_text(index)
	# close the menu and tell thing placer to use the blueprint
	pass # Replace with function body.


func _on_BuildMenuToggle_pressed():
	self.visible = not self.visible

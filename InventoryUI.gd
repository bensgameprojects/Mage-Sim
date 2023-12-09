extends Control

onready var playerCtrlInventoryGrid = $InventoryPanel/VBoxContainer/CenterContainer2/PlayerCtrlInventoryGrid
onready var inventory_panel = $InventoryPanel
onready var itemScene = preload("res://Items/Item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory_panel.hide()
	playerCtrlInventoryGrid.inventory = null

func _unhandled_input(event):
	if event.is_action_pressed("ui_inv_toggle"):
		if inventory_panel.visible:
			inventory_panel.hide()
			# unhook the inventory ctrl on close.
			playerCtrlInventoryGrid.inventory = null
		else:
			playerCtrlInventoryGrid.inventory = PlayerInventory
			inventory_panel.show()

# item is dropped and the drop_position is outside the UI bounds
#item is type InventoryItem, drop_position is a Vector2 position vector
func _on_PlayerCtrlInventoryGrid_item_dropped(item, drop_position):
	return

extends Node2D
# Item
# ID
export(int) var item_ID = -1
# Name
export(str) var item_name = "New Item"
# Description
export(str) var description = "Add item description"
# Quantity
export(bool) var has_quantity = true # might be useful for display items in stores
export(int) var quantity = 1
# Category
enum {
	MATERIAL,
	FOOD,
	INGREDIENT,
	EQUIPMENT,
	KEYITEM,
	TURNIN,
	MISC
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# this only toggles the grid not the actual ui visibility
# gotta figure out how to lay it on top
# IDK why its laid on top now prolly should look into that
# and put a background behind it...
# watch UI tutorials
func _input(event):
	if event.is_action_pressed("ui_inv_toggle"):
#		InventoryGrid.draw_grid = not InventoryGrid.draw_grid
		self.visible = not self.visible
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

extends Control

onready var playerInventoryGrid = $PlayerInventoryGrid
onready var worldInventoryGrid = $WorldInventoryGrid
onready var playerCtrlInventoryGrid = $PlayerInventoryGrid
signal item_dropped_to_floor(item)
signal item_created_in_world_inv(spawn_area,item)

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("new_dropped_item", self, "_on_new_dropped_item")

func load_inventory(savedInventory):
	playerInventoryGrid.deserialize(savedInventory)

func save_inventory():
	return playerInventoryGrid.serialize()
# this only toggles the grid not the actual ui visibility
# gotta figure out how to lay it on top
# IDK why its laid on top now prolly should look into that
# and put a background behind it...
# watch UI tutorials
func _input(event):
	if event.is_action_pressed("ui_inv_toggle"):
#		InventoryGrid.draw_grid = not InventoryGrid.draw_grid
		self.visible = not self.visible

func _on_new_dropped_item(new_item):
	# create a new item in the world inventory and set its item reference i guess
	var world_inv_item_reference = worldInventoryGrid.create_and_add_item_at_next_free_position(new_item.get_item_ID())
	if(world_inv_item_reference != null):
		new_item.set_item_reference(world_inv_item_reference)
	else:
		printerr("New Item could not be created in WorldInventoryGrid!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# item is dropped and the drop_position is outside the UI bounds
#item is type InventoryItem, drop_position is a Vector2 position vector
func _on_PlayerCtrlInventoryGrid_item_dropped(item, drop_position):
	if(drop_position.x < self.rect_position.x || drop_position.x > self.rect_position.x + self.rect_size.x || drop_position.y < self.rect_position.y || drop_position.y > self.rect_position.y + self.rect_size.y):
#		var item_properties = [item.protoset, item.prototype_id, item.properties]
		#transfer the item to the world inventory
		var succeeded = playerInventoryGrid.transfer_to(item, worldInventoryGrid, worldInventoryGrid.find_free_place(item))
#		var succeeded = playerInventoryGrid.transfer(item, worldInventoryGrid)
#		print("transfer compelte welcum to balnumng" + str(succeeded))
		# if you fail to move item from player to world, leave item in player inv
		if(succeeded):
			emit_signal("item_dropped_to_floor", item)


func _on_SpawnHandler_transfer_item_to_player_inv(itemToTransfer):
	# try to merge the item with existing stack(s) of items
	var worldInventory = itemToTransfer.get_inventory()
	var transferItemStackSize = itemToTransfer.get_property("stack_size")
	var maxStackSize = itemToTransfer.get_property("max_stack_size")
	var itemToStack = playerInventoryGrid.get_first_item_unmaxed_stack(itemToTransfer.prototype_id)
	
	while itemToStack != null and transferItemStackSize != 0:
		var receivingItemStackSize = itemToStack.get_property("stack_size")
		receivingItemStackSize = receivingItemStackSize + transferItemStackSize
		if(receivingItemStackSize > maxStackSize):
#			transferItemStackSize = receivingItemStackSize % maxStackSize
			transferItemStackSize = receivingItemStackSize - maxStackSize
			itemToStack.set_property("stack_size", maxStackSize)
		else:
			transferItemStackSize = 0
			itemToStack.set_property("stack_size", receivingItemStackSize)
		
		itemToStack = playerInventoryGrid.get_first_item_unmaxed_stack(itemToTransfer.prototype_id)
	
	# ok so itemToStack is null but we still have items left to add
	if(transferItemStackSize != 0):
		# need to update the transfer item stack size to the itemToTransfer 
		# in case that it changed above
		itemToTransfer.set_property("stack_size", transferItemStackSize)
		# attempts to move the item to the player inventory
		var free_spot = playerInventoryGrid.find_free_place(itemToTransfer)
		# returns -1 -1 if no free place can be found
		
		if free_spot == Vector2(-1,-1):
			emit_signal("item_dropped_to_floor", itemToTransfer)
		else:
			if not itemToTransfer.get_inventory().transfer_to(itemToTransfer, playerInventoryGrid, free_spot):
				# didnt work so put it back on the ground
				print("error: was not able to add to inventory! Item:" + str(itemToTransfer))
				emit_signal("item_dropped_to_floor", itemToTransfer)
	else:
		worldInventory.remove_item(itemToTransfer)


func _on_SpawnHandler_create_and_add_item_to_world_inv(spawn_area, itemID, stackSize):
	var item = worldInventoryGrid.create_and_add_item_at_next_free_position(itemID)
	if item:
		item.set_property("stack_size", stackSize)
		emit_signal("item_created_in_world_inv", spawn_area,item)
	else:
		printerr("item could not be created!")
	

extends Control

onready var playerInventoryGrid = $PlayerInventoryGrid
onready var worldInventoryGrid = $WorldInventoryGrid
onready var playerCtrlInventoryGrid = $InventoryPanelWindow/VBoxContainer/CenterContainer2/PlayerCtrlInventoryGrid
onready var pickupItemUI = $PickupItemUI
onready var inventoryPanelWindow = $InventoryPanelWindow
signal item_dropped_to_floor(item)
signal item_created_in_world_inv(spawn_area,item)
onready var itemScene = preload("res://Items/Item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	inventoryPanelWindow.visible = false

func load_inventory(savedInventory):
	playerInventoryGrid.deserialize(savedInventory)

func save_inventory():
	return playerInventoryGrid.serialize()

func _unhandled_input(event):
	if event.is_action_pressed("ui_inv_toggle"):
		inventoryPanelWindow.visible = not inventoryPanelWindow.visible

func create_new_dropped_item(new_item, stack_size):
	# create a new item in the world inventory and set its item reference i guess
	var world_inv_item_reference = worldInventoryGrid.create_and_add_item_at_next_free_position(new_item.get_item_id())
	if(world_inv_item_reference != null):
		new_item.set_item_reference(world_inv_item_reference)
		world_inv_item_reference.set_property("stack_size", stack_size)
	else:
		printerr("New Item could not be created in WorldInventoryGrid!")


# the signal will come here, just go call it in the pickup item ui
func add_to_pickup_stack(item):
	pickupItemUI.add_to_pickup_stack(item)
	
func remove_from_pickup_stack(item):
	pickupItemUI.remove_from_pickup_stack(item)

# item is dropped and the drop_position is outside the UI bounds
#item is type InventoryItem, drop_position is a Vector2 position vector
func _on_PlayerCtrlInventoryGrid_item_dropped(item, drop_position):
	return
	if(drop_position.x < self.rect_position.x || drop_position.x > self.rect_position.x + self.rect_size.x || drop_position.y < self.rect_position.y || drop_position.y > self.rect_position.y + self.rect_size.y):
#		var item_properties = [item.protoset, item.prototype_id, item.properties]
		#transfer the item to the world inventory
		var succeeded = playerInventoryGrid.transfer_to(item, worldInventoryGrid, worldInventoryGrid.find_free_place(item))
#		var succeeded = playerInventoryGrid.transfer(item, worldInventoryGrid)
		# if you fail to move item from player to world, leave item in player inv
		if(succeeded and item.get_inventory() == worldInventoryGrid):
			var new_dropped_item = itemScene.instance()
			#this needs to add the child to the world
			# under some common ysort node SpawnHandler?
			# should we just use groups and call a common method
			# for when items are dropped.
			get_tree().get_nodes_in_group(GroupConstants.SPAWNHANDLER_GROUP)[0].add_child(new_dropped_item)
			new_dropped_item.set_item_reference(item)
			new_dropped_item.set_collision_layer_bit(LayerConstants.GATHERABLE_ITEM_LAYER_BIT, true)
			new_dropped_item.set_item_id(item.prototype_id)
			new_dropped_item.set_sprite_texture(item.get_texture())
			new_dropped_item.connect("ItemEnteredPickupRange", self, "add_to_pickup_stack")
			new_dropped_item.connect("ItemExitedPickupRange", self, "remove_from_pickup_stack")
			# this position should be a nudged position around the
			# player's feet
			new_dropped_item.spawn_sprite(get_tree().get_nodes_in_group(GroupConstants.PLAYER_GROUP)[0].global_position)


func transfer_item_to_player_inv(itemToTransfer):
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
				print("error: was not able to add to inventory! Item:" + itemToTransfer.prototype_id)
				emit_signal("item_dropped_to_floor", itemToTransfer)
	else:
		worldInventory.remove_item(itemToTransfer)
		itemToTransfer.queue_free()


func _on_SpawnHandler_create_and_add_item_to_world_inv(spawn_area, itemID, stackSize):
	var item = worldInventoryGrid.create_and_add_item_at_next_free_position(itemID)
	if item:
		item.set_property("stack_size", stackSize)
		emit_signal("item_created_in_world_inv", spawn_area,item)
	else:
		printerr("item could not be created!")
	
# returns true if able to pay the cost
# and returns false if unable to afford the cost.
func deduct_cost_from_player_inv(recipe: Dictionary) -> bool:
	return playerInventoryGrid.deduct_cost(recipe["component_ids"], recipe["component_amts"])

# For now just returns true if everything is refunded and false otherwise
func refund_cost_to_player_inv(recipe: Dictionary) -> bool:
	var remaining_refund = playerInventoryGrid.refund_cost(recipe["component_ids"], recipe["component_amts"])
	for amt in remaining_refund:
		if amt > 0:
			# add to world inv
			return false
	return true

extends Control

onready var playerInventoryGrid = $PlayerInventoryGrid
onready var playerCtrlInventoryGrid = $InventoryPanelWindow/VBoxContainer/CenterContainer2/PlayerCtrlInventoryGrid
onready var pickupItemUI = $PickupItemUI
onready var inventoryPanelWindow = $InventoryPanelWindow
onready var itemScene = preload("res://Items/Item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	inventoryPanelWindow.hide()
	playerCtrlInventoryGrid.inventory = null
	Events.connect("player_pickup_item", self, "add_new_item")

func load_inventory(savedInventory):
	playerInventoryGrid.deserialize(savedInventory)

func save_inventory():
	return playerInventoryGrid.serialize()

func _unhandled_input(event):
	if event.is_action_pressed("ui_inv_toggle"):
		if inventoryPanelWindow.visible:
			inventoryPanelWindow.hide()
			# unhook the inventory ctrl on close.
			playerCtrlInventoryGrid.inventory = null
		else:
			playerCtrlInventoryGrid.inventory = playerInventoryGrid
			inventoryPanelWindow.show()


func add_new_item(item_id : String, item_count: int):
	# this returns null if action failed and returns the item
	# made or last merged into if it succeeded.
	if playerInventoryGrid.add_or_merge(item_id, item_count) == null:
		# on failure to pick up, drop the item back on the player
		Events.emit_signal("spawn_item_on_player", item_id, item_count)

# item is dropped and the drop_position is outside the UI bounds
#item is type InventoryItem, drop_position is a Vector2 position vector
func _on_PlayerCtrlInventoryGrid_item_dropped(item, drop_position):
	return


func transfer_item_to_player_inv(itemToTransfer):
	# try to merge the item with existing stack(s) of items
	var prototype_id = itemToTransfer.prototype_id
	var worldInventory = itemToTransfer.get_inventory()
	var transferItemStackSize = itemToTransfer.get_property("stack_size")
	var maxStackSize = itemToTransfer.get_property("max_stack_size")
	var itemToStack = playerInventoryGrid.get_first_item_unmaxed_stack(prototype_id)
	var amount_left = transferItemStackSize
	while itemToStack != null and amount_left != 0:
		var receivingItemStackSize = itemToStack.get_property("stack_size")
		receivingItemStackSize = receivingItemStackSize + amount_left
		if(receivingItemStackSize > maxStackSize):
#			transferItemStackSize = receivingItemStackSize % maxStackSize
			amount_left = receivingItemStackSize - maxStackSize
			itemToStack.set_property("stack_size", maxStackSize)
		else:
			amount_left = 0
			itemToStack.set_property("stack_size", receivingItemStackSize)
		
		itemToStack = playerInventoryGrid.get_first_item_unmaxed_stack(prototype_id)
	
	# ok so itemToStack is null but we still have items left to add
	if(amount_left != 0):
		# need to update the transfer item stack size to the itemToTransfer 
		# in case that it changed above
		itemToTransfer.set_property("stack_size", amount_left)
		# attempts to move the item to the player inventory
		var free_spot = playerInventoryGrid.find_free_place(itemToTransfer)
		# returns -1 -1 if no free place can be found
		
		if free_spot == Vector2(-1,-1):
			Events.emit_signal("notify_player", NotificationTypes.Notifications.ITEM_PICKUP, {"item_id": prototype_id, "amount": (transferItemStackSize - amount_left)})
			emit_signal("item_dropped_to_floor", itemToTransfer)
		else:
			if not itemToTransfer.get_inventory().transfer_to(itemToTransfer, playerInventoryGrid, free_spot):
				# didnt work so put it back on the ground
				Events.emit_signal("notify_player", NotificationTypes.Notifications.ITEM_PICKUP, {"item_id": prototype_id, "amount": (transferItemStackSize - amount_left)})
				print("error: was not able to add to inventory! Item:" + itemToTransfer.prototype_id)
				emit_signal("item_dropped_to_floor", itemToTransfer)
			else: # succeeded in adding the full amount to the inv
				Events.emit_signal("notify_player", NotificationTypes.Notifications.ITEM_PICKUP, {"item_id": prototype_id, "amount": transferItemStackSize})
	else: # succeeded in merging the ful amount to the inv
		Events.emit_signal("notify_player", NotificationTypes.Notifications.ITEM_PICKUP, {"item_id": prototype_id, "amount": transferItemStackSize})
		worldInventory.remove_item(itemToTransfer)
		itemToTransfer.queue_free()


# returns true if able to pay the cost
# and returns false if unable to afford the cost.
# returns true if the recipe is empty/null or doesnt have the required keys.
func deduct_cost_from_player_inv(recipe) -> bool:
	if recipe == null or recipe.empty() or not recipe.has_all(["component_ids", "component_amts"]):
		return true
	return playerInventoryGrid.deduct_cost(recipe["component_ids"], recipe["component_amts"])

# For now just returns true if everything is refunded and false otherwise
func refund_cost_to_player_inv(recipe: Dictionary) -> bool:
	var remaining_refund = playerInventoryGrid.refund_cost(recipe["component_ids"], recipe["component_amts"])
	for amt in remaining_refund:
		if amt > 0:
			# add to world inv
			return false
	return true

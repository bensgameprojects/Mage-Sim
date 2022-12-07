extends Control

onready var focusLabel = $FocusLabel
var pickuppableItemArray = Array()
var pickupHead = 0
signal transfer_item_to_player_inv

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _unhandled_input(event):
	if event.is_action("ui_focus_next"):
		next_item_in_pickup_stack()
	elif event.is_action("ui_focus_prev"):
		previous_item_in_pickup_stack()
	elif event.is_action("pickup_item"):
		if(!pickuppableItemArray.empty()):
			var poppedItem = pop_pickup_stack()
			emit_signal("transfer_item_to_player_inv", poppedItem.get_item_reference())
			poppedItem.queue_free()

# go to the end of the array (which is the front of the stack)
func add_to_pickup_stack(item):
	# no duplicates plz
	if not pickuppableItemArray.has(item):
		if pickuppableItemArray.size() == 0:
			pickupHead = 0
		pickuppableItemArray.push_back(item)
		show_item_pickup_prompt()
#		print("adding item, array size is: " + str(pickuppableItemArray.size()))

# seems like this is being called when an item is being picked up
# because of the itemExitedPickupRange signal in DroppedItems.
# it is useful for when it is moved out
# perhaps to pick up an item we have to disconnect the signal first?
func remove_from_pickup_stack(item):
#	print("attempting to remove item" + item.get_item_reference().get_property("id"))
	var index = pickuppableItemArray.find(item)
	if index >= 0:
#		print("erasing item")
		pickuppableItemArray.erase(item)
		pickupHead = 0
#		print("array size is now: " + str(pickuppableItemArray.size()))
		if pickuppableItemArray.size() == 0:
#			print("calling hide item prompt")
			hide_item_pickup_prompt()
		else:
			show_item_pickup_prompt()

func peek_pickup_stack():
	return pickuppableItemArray[pickupHead]

func pop_pickup_stack():
	if pickuppableItemArray.size() != 0:
#		print("popping item at pickupHead = ", pickupHead)
		var poppedItem = pickuppableItemArray.pop_at(pickupHead)
#		poppedItem.disconnect("ItemExitedPickupRange", self, "removeFromPickupStack")
		# gotta make sure that the head is still ok
		# it bein weird so just gonna set to 0 each time
#		print("resetting pickupHead to 0 and calling nextItemInPickupStack")
		pickupHead = 0
		next_item_in_pickup_stack()
		return poppedItem
	printerr("Error: popping on empty pickup stack")
	return null

func next_item_in_pickup_stack():
	if pickuppableItemArray.size() != 0:
		pickupHead = (pickupHead + 1) % pickuppableItemArray.size()
		# assign the label
		show_item_pickup_prompt()
	else:
		pickupHead = 0
		hide_item_pickup_prompt()

func previous_item_in_pickup_stack():
	if pickuppableItemArray.size() != 0:
		pickupHead = (pickupHead - 1) % pickuppableItemArray.size()
		show_item_pickup_prompt()
	else:
		pickupHead = 0
		hide_item_pickup_prompt()


# shows a item pickup prompt for whatever is at the head
func show_item_pickup_prompt():
	var itemReference = pickuppableItemArray[pickupHead].get_item_reference()
	var name = itemReference.get_property("name")
	var quantity = itemReference.get_property("stack_size")
	focusLabel.text = "F: Pick up " + str(quantity) + " " + name + "(s)"
	focusLabel.visible = true

func hide_item_pickup_prompt():
	focusLabel.visible = false

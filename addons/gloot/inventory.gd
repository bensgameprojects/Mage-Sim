extends Node
class_name Inventory
tool

signal item_added
signal item_removed
signal item_modified
signal contents_changed
signal protoset_changed

export(Resource) var item_protoset: Resource setget _set_item_protoset
var _items: Array = []

const KEY_NODE_NAME: String = "node_name"
const KEY_ITEM_PROTOSET: String = "item_protoset"
const KEY_ITEMS: String = "items"
const Verify = preload("res://addons/gloot/verify.gd")


func _get_configuration_warning() -> String:
	if item_protoset == null:
		return "This inventory node has no protoset. Set the 'item_protoset' field to be able to " \
		+ "populate the inventory with items."
	return ""


func _set_item_protoset(new_item_protoset: Resource) -> void:
	assert((new_item_protoset is ItemProtoset) || (new_item_protoset == null), \
		"item_protoset must be an ItemProtoset resource!")
	
	item_protoset = new_item_protoset
	emit_signal("protoset_changed")
	update_configuration_warning()


static func _get_item_script() -> Script:
	return preload("inventory_item.gd")


func _enter_tree():
	for child in get_children():
		if child is InventoryItem:
			_items.append(child)


func _exit_tree():
	_items.clear()


func _ready() -> void:
	connect("item_added", self, "_on_item_added")
	connect("item_removed", self, "_on_item_removed")

	for item in get_items():
		_connect_item_signals(item)


func _on_item_added(item: InventoryItem) -> void:
	_items.append(item)
	emit_signal("contents_changed")
	_connect_item_signals(item)


func _on_item_removed(item: InventoryItem) -> void:
	_items.erase(item)
	emit_signal("contents_changed")
	_disconnect_item_signals(item)


func move_item(from: int, to: int) -> void:
	assert(from >= 0)
	assert(from < _items.size())
	assert(to >= 0)
	assert(to < _items.size())
	if from == to:
		return

	var item = _items[from]
	_items.remove(from)
	_items.insert(to, item)

	emit_signal("contents_changed")


func get_item_index(item: InventoryItem) -> int:
	return _items.find(item)


func get_item_count() -> int:
	return _items.size()


func _connect_item_signals(item: InventoryItem) -> void:
	if !item.is_connected("protoset_changed", self, "_emit_item_modified"):
		item.connect("protoset_changed", self, "_emit_item_modified", [item])
	if !item.is_connected("prototype_id_changed", self, "_emit_item_modified"):
		item.connect("prototype_id_changed", self, "_emit_item_modified", [item])
	if !item.is_connected("properties_changed", self, "_emit_item_modified"):
		item.connect("properties_changed", self, "_emit_item_modified", [item])


func _disconnect_item_signals(item:InventoryItem) -> void:
	if item.is_connected("protoset_changed", self, "_emit_item_modified"):
		item.disconnect("protoset_changed", self, "_emit_item_modified")
	if item.is_connected("prototype_id_changed", self, "_emit_item_modified"):
		item.disconnect("prototype_id_changed", self, "_emit_item_modified")
	if item.is_connected("properties_changed", self, "_emit_item_modified"):
		item.disconnect("properties_changed", self, "_emit_item_modified")


func _emit_item_modified(item: InventoryItem) -> void:
	emit_signal("item_modified", item)


func get_items() -> Array:
	return _items


func has_item(item: InventoryItem) -> bool:
	return item.get_parent() == self


func add_item(item: InventoryItem) -> bool:
	if item == null || has_item(item):
		return false

	if item.get_parent():
		item.get_parent().remove_child(item)

	add_child(item)
	if Engine.editor_hint:
		item.owner = get_tree().edited_scene_root
	return true


func create_and_add_item(prototype_id: String) -> InventoryItem:
	var item: InventoryItem = InventoryItem.new()
	item.prototype_id = prototype_id
	if add_item(item):
		return item
	else:
		item.free()
		return null

func create_and_add_item_amount(prototype_id: String, amount: int) -> InventoryItem:
	var item: InventoryItem = InventoryItem.new()
	item.prototype_id = prototype_id
	if add_item(item):
		item.set_property("stack_size", amount)
		return item
	else:
		item.free()
		return null

func remove_item(item: InventoryItem) -> bool:
	if item == null || !has_item(item):
		return false

	remove_child(item)
	return true


func remove_all_items() -> void:
	while get_child_count() > 0:
		remove_child(get_child(0))
	_items = []


func get_item_by_id(prototype_id: String) -> InventoryItem:
	for item in get_items():
		if item.prototype_id == prototype_id:
			return item
			
	return null

# Will get all the item stacks that match the given prototype_id
func get_all_items_by_id(prototype_id: String) -> Array:
	var item_stacks = []
	for item in get_items():
		if item.prototype_id == prototype_id:
			item_stacks.append(item)
	return item_stacks

# Will get the total number of an item in an inventory
# adding together all the stacks of that item if any.
func get_item_count_by_id(prototype_id: String) -> int:
	var count = 0
	for item in get_items():
		if item.prototype_id == prototype_id:
			count += item.get_property("stack_size")
	return count

# given an array of ids, get_item_counts_by_ids returns a dictionary
# where the prototype_ids are the keys and the value is the total
# amount of that item in the inventory across all stacks.
# This method is more efficient than repeatedly calling
# get_item_count_by_id for each item.
func get_item_counts_by_ids(prototype_ids: Array) -> Dictionary:
	var result = {}
	for prototype_id in prototype_ids:
		result[prototype_id] = 0
	for item in get_items():
		if prototype_ids.has(item.prototype_id):
			result[item.prototype_id] += item.get_property("stack_size")
	return result

# this function will iterate through all the items in your inventory
# and return the first item that matches the prototype id with some free
# space in the stack
# if it doesn't find one then it will return null 
func get_first_item_unmaxed_stack(prototype_id: String) -> InventoryItem:
	for item in get_items():
		if item.prototype_id == prototype_id && item.get_property("stack_size") != item.get_property("max_stack_size"):
			return item
	return null

func has_item_by_id(prototype_id: String) -> bool:
	return get_item_by_id(prototype_id) != null

# can_afford_recipe(component_ids: Array, component_amts: Array)
# Will check that the inventory has all of the required items and amounts
# given by the arrays. Returns true if can, false if not.
func can_afford_recipe(component_ids: Array, component_amts: Array) -> bool:
	# crash program if these arent the same size
	assert(component_ids.size() == component_amts.size())
	# get the amts of each item in the inventory by their ids
	var result = get_item_counts_by_ids(component_ids)
	for i in range(component_ids.size()):
		if result[component_ids[i]] < component_amts[i]:
			return false
	return true

# This function will remove the amounts and ids specified in the
# given arrays. Will refund the items if it can't complete
# returns true if the cost was deducted and false otherwise.
func deduct_cost(component_ids: Array, component_amts: Array) -> bool:
	var component_debt = component_amts.duplicate(true)
	var items_to_remove = []
#	print("component_debt", component_debt)
	# first check if we can afford the recipe:
	if can_afford_recipe(component_ids, component_amts):
		#if so, remove all the items and specified amounts:
		for item in get_items():
			var index = component_ids.find(item.prototype_id)
#			if index == -1:
#				print("Couldn't find " + item.prototype_id + " in", component_ids)
#			else:
#				print("Found " + item.prototype_id + " in %s at index %s", component_ids,index)
			if index != -1 and component_debt[index] > 0:
				var stack_size = item.get_property("stack_size")
				if component_debt[index] < stack_size:
					stack_size -= component_debt[index]
#					print("Removed " + str(component_debt[index]) + " of " + item.get_property("name") + " from stack of " + str(stack_size + component_debt[index]))
					component_debt[index] = 0
					item.set_property("stack_size", stack_size)
					emit_signal("contents_changed")
				else: # the stack is smaller than or equal to the amount needed
					# pay off the recipe debt
#					print("Removing the rest(" + str(stack_size) + ") of the stack for item " + item.get_property("name"))
					component_debt[index] -= stack_size
					item.set_property("stack_size", 0)
					# add to an array to remove after this for loop
					# otherwise the get_items array gets changed while this loop
					# is running and it causes logical errors.
					items_to_remove.append(item)
					emit_signal("contents_changed")
#		print("component debt is now ", component_debt)
#		print("")
		# Ensure that we were able to take everything
		var debt_count = 0
		for debt in component_debt:
			debt_count += debt
		if debt_count == 0:
			# success!
			# Remove any items that now have a stack size of 0
			for item in items_to_remove:
				if is_instance_valid(item):
					remove_item(item)
					item.queue_free()
					emit_signal("contents_changed")
			return true
		# else something went wrong and we cant afford the recipe after all
		else: 
			# refund
			# calculate the amount of each we need to refund:
			for i in range(component_debt.size()):
				component_debt[i] = component_amts[i] - component_debt[i]
			# give back the items to any existing stacks
			for item in get_items():
				# check if this item is one we're looking for
				var index = component_ids.find(item.prototype_id)
				# if so and we still have some to refund then add to the stack
				# if able
				if (index != -1 and component_debt[index] > 0):
					var stack_size = item.get_property("stack_size")
					var max_stack_size = item.get_property("max_stack_size")
					var available_space = max_stack_size - stack_size
					if available_space >= component_debt[index]:
						stack_size += component_debt[index]
						item.set_property("stack_size", stack_size)
						component_debt[index] = 0
					elif available_space > 0:
						component_debt[index] -= available_space
						item.set_property("stack_size", max_stack_size)
			# any remaining debt should be added as new items if space permits
			for i in range(component_debt.size()):
				if component_debt[i] > 0:
					var item = create_and_add_item_amount(component_ids[i], component_debt[i])
					var max_stack_size = item.get_property("max_stack_size")
					# make new full stacks of the item until you make one not full stack
					# or you fail to add item to inventory
					# which we could improve to drop them on the floor
					while item != null and component_debt[i] > max_stack_size:
						component_debt[i] = component_debt[i] - max_stack_size
						item.set_property("stack_size", max_stack_size)
						item = create_and_add_item_amount(component_ids[i], component_debt[i])
		emit_signal("contents_changed")
	return false

# This function will add the cost of the given recipe
# to the inventory it is called on.
# It will return a new array containing the amounts of each component
# that could not be refunded. (If everything was refunded the array will 
# be all zeroes.
# This is useful for adding anything that can't be refunded to player inv
# to the world inventory.
func refund_cost(component_ids: Array, component_amts: Array) -> Array:
	var component_debt : Array = component_amts.duplicate(true)
# give back the items to any existing stacks
	for item in get_items():
		# check if this item is one we're looking for
		var index = component_ids.find(item.prototype_id)
		# if so and we still have some to refund then add to the stack
		# if able
		if (index != -1 and component_debt[index] > 0):
			var stack_size = item.get_property("stack_size")
			var max_stack_size = item.get_property("max_stack_size")
			var available_space = max_stack_size - stack_size
			if available_space >= component_debt[index]:
				stack_size += component_debt[index]
				item.set_property("stack_size", stack_size)
				component_debt[index] = 0
			elif available_space > 0:
				component_debt[index] -= available_space
				item.set_property("stack_size", max_stack_size)
	# any remaining debt should be added as new items if space permits
	for i in range(component_debt.size()):
		if component_debt[i] > 0:
			var item = create_and_add_item_amount(component_ids[i], component_debt[i])
			var max_stack_size = item.get_property("max_stack_size")
			# make new full stacks of the item until you make one not full stack
			# or you fail to add item to inventory
			while item != null and component_debt[i] > max_stack_size:
				component_debt[i] = component_debt[i] - max_stack_size
				item.set_property("stack_size", max_stack_size)
				item = create_and_add_item_amount(component_ids[i], component_debt[i])
	emit_signal("contents_changed")
	return component_debt

func transfer(item: InventoryItem, destination: Inventory) -> bool:
	if remove_item(item):
		return destination.add_item(item)

	return false


func reset() -> void:
	clear()
	item_protoset = null


func clear() -> void:
	for item in get_items():
		item.queue_free()
	remove_all_items()


func serialize() -> Dictionary:
	var result: Dictionary = {}

	result[KEY_NODE_NAME] = name
	result[KEY_ITEM_PROTOSET] = item_protoset.resource_path
	if !get_items().empty():
		result[KEY_ITEMS] = []
		for item in get_items():
			result[KEY_ITEMS].append(item.serialize())

	return result


func deserialize(source: Dictionary) -> bool:
	if !Verify.dict(source, true, KEY_NODE_NAME, TYPE_STRING) ||\
		!Verify.dict(source, true, KEY_ITEM_PROTOSET, TYPE_STRING) ||\
		!Verify.dict(source, false, KEY_ITEMS, TYPE_ARRAY, TYPE_DICTIONARY):
		return false

	reset()

	name = source[KEY_NODE_NAME]
	item_protoset = load(source[KEY_ITEM_PROTOSET])
	if source.has(KEY_ITEMS):
		var items = source[KEY_ITEMS]
		for item_dict in items:
			var item = _get_item_script().new()
			item.deserialize(item_dict)
			assert(add_item(item), "Failed to add item '%s'. Inventory full?" % item.prototype_id)

	return true

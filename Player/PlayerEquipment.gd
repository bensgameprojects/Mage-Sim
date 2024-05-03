extends Node2D

# Each equipment slot is an inventory with 1 slot.
# The equip function handles adding and transferring items.
# Declare member variables here.
onready var helm_slot = $Helm
onready var chest_slot = $Chest
onready var legs_slot = $Legs
onready var feet_slot = $Feet
onready var gloves_slot = $Gloves
onready var weapon_slot = $Weapon

func equip(equipment_item: InventoryItem):
	var category = equipment_item.get_property("category")
	var slot = equipment_item.get_property("slot")
	if category != null and slot != null and category == "Equipment":
		match slot:
			"Helm":
				_equip_item(helm_slot, equipment_item)
			"Chest":
				_equip_item(chest_slot, equipment_item)
			"Legs":
				_equip_item(legs_slot, equipment_item)
			"Feet":
				_equip_item(feet_slot, equipment_item)
			"Gloves":
				_equip_item(gloves_slot, equipment_item)
			"Weapon":
				_equip_item(weapon_slot, equipment_item)
			_:
				print("Error: Unable to equip, unkown slot type ", slot)
	else: #item is not an equipment
		return

# Takes an equipment slot + an appropriate equipment item and adds/transfers it
func _equip_item(slot: InventoryGrid, equipment_item: InventoryItem):
	# get the source inventory that the equipment item is in
	var source_inventory = equipment_item.get_inventory()
	# remove it from that inventory
	source_inventory.remove_item(equipment_item)
	# attempt to equip the item
	if not slot.add_item(equipment_item):
		# if false then an existing equipment exists in the slot
		# the slots always contain just 1 equipment so this array index will work.
		var existing_equipment : InventoryItem = slot.get_items()[0]
		# Unequip the existing equipment into the source inventory of the new equipment
		slot.transfer(existing_equipment, source_inventory)
		# add the new equipment to the slot.
		if not slot.add_item(equipment_item):
			# if for some reason that STILL didnt work, put the equipment back into the
			# inventory that it came from.
			source_inventory.add_item(equipment_item)
			# print an error because it should not happen.
			print("Error: Unable to equip ", equipment_item.get_property("name"), " due to an inventory transfer error.")

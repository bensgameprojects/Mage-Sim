extends Reference
class_name Equipment
# reference counted objects for equipment.
# this is a prototype class.
# Each equipment item will have a script extending this one
# in res://Items/Equipment/
# whose filename matches the id of the item in the item protoset.
# This is so they can be loaded simply without needing a link to their resource.

var description : String = ""
# Stat objects can be declared
# here or unique spell Modifiers.

# an equip function
# to be implemented by the equipment.
# will take stat values and add them to the equipment
func equip():
	pass

# an unequip function
func unequip():
	pass

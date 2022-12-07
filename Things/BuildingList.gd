extends Node

export(Resource) var building_protoset: Resource setget _set_building_protoset


func _set_building_protoset(new_building_protoset: Resource) -> void:
	assert((new_building_protoset is ItemProtoset) || (new_building_protoset == null), \
		"building_protoset must be an ItemProtoset resource!")

	building_protoset = new_building_protoset

func get_building_by_id(building_id):
	return building_protoset.get(building_id)

#might want a function to get all buildings that are unlocked
# and dynamically update that list
func get_unlocked_buildings():
	return get_default_unlocked_buildings()

func get_default_unlocked_buildings():
	return building_protoset.get_all_items_containing_property("default_unlock_status", true)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

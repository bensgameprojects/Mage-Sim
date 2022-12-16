extends Node
"""
This building list references the Building Protoset which is a JSON
containing the following properties:
	id: String
		must match the name of the Thing so that
		res://Things/Things/<id>Thing.tscn is the path to the scene.
		similarly, res://Things/Blueprints/<id>Blueprint.tscn is the path
		to the blueprint
	name: String
		The name to be used for menus/other displays
	description: String
		The description used for display
	category: String
		The category that the thing belongs to. Exs: power, crafter, etc
	component_ids: Array<String>
		An array of item id's needed to construct the building 
	component_amts: Array<Int>
		An array of amounts corresponding to how many of each item is needed
		to construct the building. Note that component_amts.length == component_ids.length
		building id needs component_amts[0] of component_ids[0] item etc.
	default_unlock_status: Bool
		Whether this building is unlocked by default or not
		This property is (will be) used to populate the unlock_status dict
		when a new game is started.

Lastly, the unlock_status dictionary uses the building id as a key and the 
corresponding value a bool of whether the building is unlocked (and therefore
can show up in the build menu list). This dictionary will be part of the 
save and load states of the game.
"""

export(Resource) var building_protoset: Resource setget _set_building_protoset

var unlock_status : Dictionary = {}

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
	return building_protoset.get_all_items_with_matching_property("default_unlock_status", true)

func create_unlock_status():
	for prototype in building_protoset.get_all_items_with_matching_property("default_unlock_status", true):
		unlock_status[prototype["id"]] = true
	for prototype in building_protoset.get_all_items_with_matching_property("default_unlock_status", false):
		unlock_status[prototype["id"]] = false

func save_unlock_status() -> Dictionary:
	return unlock_status

func load_unlock_status(unlock_status_dict: Dictionary) -> void:
	unlock_status = unlock_status_dict

func get_unlock_status_by_id(id: String) -> bool:
	if(unlock_status.has(id)):
		return unlock_status[id]
	return false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

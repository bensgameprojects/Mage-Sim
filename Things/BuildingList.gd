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

Also there are two dictionaries, things and blueprints which contain 
packed scenes of each Thing in the Things/Things/ folder. They are used by
the ThingPlacer to place things.

Lastly, the unlock_status dictionary uses the building id as a key and the 
corresponding value a bool of whether the building is unlocked (and therefore
can show up in the build menu list). This dictionary will be part of the 
save and load states of the game.
"""
const BASE_PATH := "res://Things"
const BLUEPRINT := "Blueprint.tscn"
const THING := "Thing.tscn"

export(Resource) var building_protoset: Resource setget _set_building_protoset

var unlock_status : Dictionary = {}
var things := {}
var blueprints := {}

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

func get_thing_name_from(node: Node) -> String:
	if node:
		if node.has_method("get_thing_name"):
			return node.get_thing_name()
		
		var filename := node.filename.substr(node.filename.rfind("/")+ 1)
		filename = filename.replace(BLUEPRINT,"").replace(THING,"")
		
		return filename
	return ""

func _find_things_in(path: String) -> void:
	var directory := Directory.new()
	var error := directory.open(path)
	if error != OK:
		print("Library Error: %s" % error)
		return
	
	error = directory.list_dir_begin(true,true)
	
	if error != OK:
		print("Library Error: %s" % error)
		return
	
	var filename := directory.get_next()
	
	while not filename.empty():
		if directory.current_is_dir():
			_find_things_in("%s/%s" % [directory.get_current_dir(), filename])
		else:
			if filename.ends_with(BLUEPRINT):
				blueprints[filename.replace(BLUEPRINT, "")] = load("%s/%s" % [directory.get_current_dir(), filename])
			if filename.ends_with(THING):
				things[filename.replace(THING, "")] = load(
					"%s/%s" % [directory.get_current_dir(), filename]
				)
		filename = directory.get_next()

func get_recipe_by_id(building_id) -> Dictionary:
	var result = {}
	var building_info = get_building_by_id(building_id)
	if building_info != null:
		result["component_ids"] = building_info["component_ids"]
		result["component_amts"] = building_info["component_amts"]
	else: # this case shouldn't happen but its a failsafe
		result["component_ids"] = Array()
		result["component_amts"] = Array()
	return result
# Called when the node enters the scene tree for the first time.
func _ready():
	_find_things_in(BASE_PATH)

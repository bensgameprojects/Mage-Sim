extends Node


export(Resource) var spell_protoset : Resource setget _set_spell_protoset


func _set_spell_protoset(new_spell_protoset: Resource) -> void:
	assert((new_spell_protoset is ItemProtoset) || (new_spell_protoset == null), \
		"spell_protoset must be an ItemProtoset resource!")

	spell_protoset = new_spell_protoset

# Called when the node enters the scene tree for the first time.
#func _ready():
#	print(get_spell_data_by_id("FireAttack1"))

func get_spell_data_by_id(item_id : String) -> Dictionary:
	return spell_protoset.get(item_id)

func get_spell_name_by_id(item_id : String) -> String:
	return spell_protoset.get(item_id)["name"]

func get_unlocked_spell_ids() -> Array:
	var return_value : Array = []
	for key in spell_protoset._prototypes.keys():
		var prototype = spell_protoset._prototypes[key]
		if(prototype.has("is_unlocked") and prototype["is_unlocked"] == true):
			return_value.append(prototype["id"])
	return return_value

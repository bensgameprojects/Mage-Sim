extends Node


export(Resource) var item_protoset : Resource setget _set_item_protoset

func _set_item_protoset(new_item_protoset: Resource) -> void:
	assert((new_item_protoset is ItemProtoset) || (new_item_protoset == null), \
		"item_protoset must be an ItemProtoset resource!")

	item_protoset = new_item_protoset

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

func get_item_data_by_id(item_id) -> Dictionary:
	return item_protoset.get(item_id)

func get_item_name_by_id(item_id) -> String:
	return item_protoset.get(item_id)["name"]
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

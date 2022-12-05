extends Node

export(Resource) var recipe_protoset: Resource setget _set_recipe_protoset


func _set_recipe_protoset(new_recipe_protoset: Resource) -> void:
	assert((new_recipe_protoset is ItemProtoset) || (new_recipe_protoset == null), \
		"recipe_protoset must be an ItemProtoset resource!")

	recipe_protoset = new_recipe_protoset

func get_recipe_by_id(recipe_id):
	return recipe_protoset.get(recipe_id)

func get_all_recipes_for_item(item_id) -> Array:
	return recipe_protoset.get_all_items_containing_property("product_item_id", item_id)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


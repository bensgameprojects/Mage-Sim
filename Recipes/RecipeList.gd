extends Node

"""
	The RecipeList is a global node (autoloaded singleton) containing a recipe protoset
	accessible in the inspector. It is a JSON array and the recipe protoset is
	using the ItemProtoset class to parse the resulting dictionaries.
	Each recipe is a dictionary in the following format:
	
	{
		"id":"lumber",
		"name":"Lumber",
		"producing_things":["Farm"],
		"componentIDs":[],
		"componentAmts":[],
		"product_item_id":"Lumber",
		"amount_produced":1,
		"base_craft_time":1
	}
	id: this is the key used to identify the recipe uniquely
	name: name of the recipe for display
	producing_things : An array of strings of keys for things that can make this recipe
	componentIDs: Array of strings of item.prototype_id 's that this recipe requires
	componentAmts: Array of corresponding amounts for each item key in componentIDs each n > 0
	product_item_id : A string item.prototype_id that this recipe produces
	amount_product : The amount of product item that this recipe produces
	base_craft_time : The time in seconds it takes to complete this recipe.
	
"""

export(Resource) var recipe_protoset: Resource setget _set_recipe_protoset


func _set_recipe_protoset(new_recipe_protoset: Resource) -> void:
	assert((new_recipe_protoset is ItemProtoset) || (new_recipe_protoset == null), \
		"recipe_protoset must be an ItemProtoset resource!")

	recipe_protoset = new_recipe_protoset

func get_recipe_by_id(recipe_id):
	return recipe_protoset.get(recipe_id)

# 
func get_all_recipes_for_item(item_id) -> Array:
	return recipe_protoset.get_all_items_containing_property("product_item_id", item_id)

# A function to return an array of recipe dictionaries for each the producing_thing id given
func get_all_recipes_for_thing(thing_id) -> Array:
	return recipe_protoset.get_all_items_containing_property("producing_things", thing_id)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


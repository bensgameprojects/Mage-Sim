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
		"component_ids":[],
		"component_amts":[],
		"product_item_id":"Lumber",
		"amount_produced":1,
		"base_craft_time":1
	}
	id: this is the key used to identify the recipe uniquely
	name: name of the recipe for display
	producing_things : An array of strings of keys for things that can make this recipe
	component_ids: Array of strings of item.prototype_id 's that this recipe requires
	component_amts: Array of corresponding amounts for each item key in component_ids each n > 0
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

# Returns a string listing the requirements of the recipe
# from the given recipe dictionary or recipe_id
# Output looks like: "1 Coal, 1 Scroll, 3 Mushroom" or "None." for no requirements.
func build_requirements_string(recipe_or_id) -> String:
	if recipe_or_id == null:
		return "None."
	var requirements_string = ""
	# If it is a string then its an id so replace it to make a dictionary
	if recipe_or_id is String:
		recipe_or_id = recipe_protoset.get(recipe_or_id)
	if recipe_or_id is Dictionary and recipe_or_id.has_all(["component_ids","component_amts"]):
		for i in range(recipe_or_id["component_ids"].size()):
			requirements_string += str(recipe_or_id["component_amts"][i]) + " " +  ItemsList.get_item_name_by_id(recipe_or_id["component_ids"][i])
			if i < recipe_or_id["component_ids"].size() - 1:
				requirements_string += ", "
	else:
		requirements_string = "None."
	return requirements_string
# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


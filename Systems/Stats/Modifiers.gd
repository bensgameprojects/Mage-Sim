extends Object
class_name Modifiers
# Dict of modifiers for unique spells.
# Keyed by spell_id, whose value is a modifier block
# with the same keys as the spell_info dict.
# Each key also has another nested dict for additive("add") and
# multiplicative("mult") bonuses.
# A unique spell modifier may be from a stat on an equipment 
# or a temporary effect.
# every key is optional except id and "add" and "mult" are optional.
# if nothing is specified it will be set to 0 when added for the first time.
"""
modifier_dict = {
	"id":"Firebolt",
	"damage":{
				"add": 2
				"mult": 0.25
			}
	"knockback_speed": {
				"add": 100
				"mult": 0.5
			}
}
"""

var modifiers : Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# a given spell buff may not have both types of bonus for each keyword
# it is modifying. This function fills those missing entries with 0's
func _add_missing_keys(modifier_dict: Dictionary) -> Dictionary:
	for key in modifier_dict:
		if key == "id":
			continue
		else: # its a keyword we need add/mult for.
			# set up any missing keys.
			if not modifier_dict[key].has("add"):
				modifier_dict[key]["add"] = 0
			if not modifier_dict[key].has("mult"):
				modifier_dict[key]["mult"] = 0.0
	return modifier_dict

# Adds a modifier dict to the dictionary, merging duplicates
# this code is not clean but itll have to do until the inventory gets overhauled.
func add(modifier_dict : Dictionary):
	modifier_dict = _add_missing_keys(modifier_dict)
	var spell_id = modifier_dict["id"]
	# no modifiers for this spell are present so add it
	if not modifiers.has(spell_id):
		modifiers[spell_id] = modifier_dict
	# if we already have a modifier for this spell, merge the dicts.
	else:
		# for each key that the modifier has, ie damage, knockback whatever
		for damage_key in modifier_dict:
			# skip id
			if damage_key == "id":
				continue
			# if the existing modifier entry has that key already
			# we need to add the "add" and "mult" fields.
			elif modifiers[spell_id].has(damage_key):
					# dict for given spell_id, sub-dict for the keyword (damage, etc), # sub-dict for additive bonus
					modifiers[spell_id][damage_key]["add"] += modifier_dict[damage_key]["add"]
					# dict for given spell_id, sub-dict for the keyword (damage, etc), # sub-dict for mult bonus
					modifiers[spell_id][damage_key]["mult"] += modifier_dict[damage_key]["mult"]
			# no modifier keyword (damage,etc) already so add it
			else:
				modifiers[spell_id][damage_key] = modifier_dict[spell_id][damage_key]

# get the modifiers for a spell_id
# if none it returns an empty dict
func get(spell_id: String) -> Dictionary:
	if modifiers.has(spell_id):
		return modifiers[spell_id]
	else:
		return {}

## Sub-class of the simulation that keeps track of all things and their location
## using dictionary keys. Emits signals when the player places or removes things.
class_name ThingTracker
extends Reference

## A Dictionary of things, keyed using `Vector2` tilemap coordinates.
var things := {}

## Adds an thing to the dictionary so we can prevent other things from taking
## the same location.
func place_thing(thing, cellv: Vector2) -> void:
	# If the cell is already taken, refuse to add it again.
	if things.has(cellv):
		return

	# Add the thing keyed by its coordinates on the map.
	things[cellv] = thing
	# Emit the signal about the new thing.
	Events.emit_signal("thing_placed", thing, cellv)


## Removes an thing from the dictionary so other things can take its place
## in its location on the map.
func remove_thing(cellv: Vector2) -> void:
	# Refuse to function if the thing does not exist.
	if not things.has(cellv):
		return

	# Get the thing, queue it for deletion, and emit a signal about
	# its removal.
	var thing = things[cellv]
	var _result := things.erase(cellv)
	Events.emit_signal("thing_removed", thing, cellv)
	thing.queue_free()


## Returns true if there is an thing at the given location.
func is_cell_occupied(cellv: Vector2) -> bool:
	return things.has(cellv)


## Returns the thing at the given location, if it exists, or null otherwise.
func get_thing_at(cellv: Vector2) -> Node2D:
	if things.has(cellv):
		return things[cellv]
	else:
		return null

# This function generates the save state dictionary for all of the things
# keyed by their grid position in the world.
# The corresponding load function for this save_dict is in the ThingPlacer
# which will place all the things back into their spots and call load on each one
# with the values stored here.
func save() -> Dictionary:
	if things.empty():
		return {}
	else:
		var save_dict = {}
		# each key gets a unique index for the save
		# its grid position is saved as a string in the thing's dict.
		var index = 1
		for key in things.keys():
			if things[key].has_method("save"):
				var thing_dict = things[key].save()
				thing_dict["grid_position"] = var2str(key)
				save_dict[var2str(index)] = thing_dict
				index += 1
		return save_dict


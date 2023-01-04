class_name WorkSystem
extends Node

# Dictionary which maps the location of things with a WorkComponent as keys
# and a reference to the component as their value.
# This allows us to know where there are machines that can craft items on the map
var workers := {}

# Connect to the global events to register with the system.
func _init() -> void:
	Events.connect("systems_ticked", self, "_on_systems_ticked")
	Events.connect("thing_placed", self, "_on_thing_placed")
	Events.connect("thing_removed", self, "_on_thing_removed")

# Perform the work on each of the workers when the system is ticked
func _on_systems_ticked(delta: float) -> void:
	for worker in workers.keys():
		workers[worker].work(delta)

# If the thing is a worker add it to the workers list
func _on_thing_placed(thing, cellv: Vector2) -> void:
	if thing.is_in_group(Types.WORKERS):
		workers[cellv] = _get_work_component_from(thing)

# Remove the given thing from the workers list when erased from the
# Thing tracker
func _on_thing_removed(thing, cellv: Vector2) -> void:
	var _erased := workers.erase(cellv)


# Gets the first node that is a WorkComponent from the thing's children
func _get_work_component_from(thing) -> WorkComponent:
	for child in thing.get_children():
		if child is WorkComponent:
			return child
	return null


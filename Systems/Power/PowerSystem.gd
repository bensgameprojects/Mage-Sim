# Holds references to things in the world, and a series of paths that
# fo from power sources to power receivers. Every system tick, it sends
# power from the sources to the receivers in order.
class_name PowerSystem
extends Node

# Holds a set of power source components keyed by their map position. We keep
# track of components to create "paths" that go from source to receiver,
# which informs the system update loop to notify those components of power flow.
var power_sources := {}

# Holds a set of power receiver components keyed by their map position.
# Same purpose as power sources, we use them to create paths between source
# and receiver used in the update loop
var power_receivers := {}

# Holds a set of entities that transmit power, like pipes
# keyeed by their map position. Used exclusively to
# create a path from a source to receiver(s).
var power_movers := {}

# An array of 'power paths'. Those arrays are map positions with
# [0] being the location of a power source and the rest being receivers.
# We use these ower paths in the update loop to calculate the amount
# of power in any given path *which has one source and
# one or more receivers and inform the source and receivers of the final number
var paths := []

# The cells that are already verified while building a power path.
# This allows us to skip revisiting cells that are already in the list
# so we only travel outwards.
var cells_travelled := []

# We use this set to keep track of how much power each receiver has already
# gotten. If you have two power sources with '10' units of power each
# feeing a machine that takes '20', then each will provide '10' over
# both paths.
var receivers_already_provided := {}

func _init() -> void:
	Events.connect("thing_placed", self, "_on_thing_placed")
	Events.connect("thing_removed", self, "_on_thing_removed")
	Events.connect("systems_ticked", self, "_on_systems_ticked")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Searches for a PowerSource component in the thing's children. Returns
# null if missing.
func _get_power_source_from(thing: Node) -> PowerSource:
	# For each child in the thing
	for child in thing.get_children():
		# Return the child if it's the component we need
		if child is PowerSource:
			return child
	return null

# Searches for a PowerReceiver component in the thing's children.
# Returns null if missing
func _get_power_receiver_from(thing: Node) -> PowerReceiver:
	for child in thing.get_children():
		if child is PowerReceiver:
			return child
	return null

func _on_thing_placed(thing, cellv: Vector2) -> void:
	# A running tally of if we should update paths. If the new thing
	# is in none of the power groups, we don't need to update anything
	# so false is the defauls
	var retrace := false
	
	# Check if the thing is in the power sources or receivers groups.
	# Get its component using a helper function and trigger a power path update
	if thing.is_in_group(Types.POWER_SOURCES):
		power_sources[cellv] = _get_power_source_from(thing)
		retrace = true
	
	if thing.is_in_group(Types.POWER_RECEIVERS):
		power_receivers[cellv] = _get_power_receiver_from(thing)
		retrace = true
	
	# If a power mover, store the thing and trigger a power path update
	if thing.is_in_group(Types.POWER_MOVERS):
		power_movers[cellv] = thing
		retrace = true
	
	# update the power paths only if necessary
	if retrace:
		_retrace_paths()

# Detects when the simulation removes a thing. If any of our dictionaries held
# this location, erase it, and trigger a path update
func _on_thing_removed(_thing, cellv: Vector2) -> void:
	# 'Dictionary.erase()' returns true if it found the key and erased it
	var retrace := power_sources.erase(cellv)
	# Note the use of 'or' below.
	retrace = power_receivers.erase(cellv) or retrace
	retrace = power_movers.erase(cellv) or retrace
	
	# Update the power paths only if necessary
	if retrace:
		_retrace_paths()
		
func _retrace_paths() -> void: 
	# Clear old paths
	paths.clear()
	
	# For each power source...
	for source in power_sources.keys():
		# ... start a brand new path trace so all cells are possible contenders
		cells_travelled.clear()
		# Trace the path from the current cell location with an array
		# with the source's cell as index 0
		var path := _trace_path_from(source, [source])
		
		#add the result to the paths array
		paths.push_back(path)


## Recursively trace a path from the source cell outwards, skipping already
## visited cells, going through cells recognized by the power system.
func _trace_path_from(cellv: Vector2, path: Array) -> Array:
	# As soon as we reach any given cell, we keep track that we've already visited it.
	# Recursive functions are sensitive to overflowing, so this ensures we won't
	# travel back and forth between two cells forever until the game crashes.
	cells_travelled.push_back(cellv)

	# The default direction for most components, like the generator, is omni-directional,
	# that's UP + LEFT + RIGHT + DOWN in our Types.
	var direction := 15
	# If the current cell is a power source component, use _its_ direction instead.
	if power_sources.has(cellv):
		direction = power_sources[cellv].output_direction

	# Get the power receivers that are neighbors to this cell, if there are any,
	# based on the direction.
	var receivers := _find_neighbors_in(cellv, power_receivers, direction)
	for receiver in receivers:
		if not receiver in cells_travelled and not receiver in path:
			# Create an integer that indicates the direction power
			# is travelling in to compare it to the receiver's direction.
			# For example, if the power is traveling from left to right but
			# the receiver does not accept power coming from _its_ left, it should
			# not be in the list.
			var combined_direction := _combine_directions(receiver,cellv)
			# Get the power receiver
			var power_receiver: PowerReceiver = power_receivers[receiver]
			# If the current directions does not match any of the receiver's
			# possible directions ( using the binary and operator, &, to check
			# if the number fits inside the other), skip this receiver and 
			# move on to the next one.
			if (
				(
					combined_direction & Types.Direction.RIGHT != 0
					and power_receiver.input_direction & Types.Direction.LEFT == 0
				)
				or (
					combined_direction & Types.Direction.DOWN != 0
					and power_receiver.input_direction & Types.Direction.UP == 0
				)
				or (
					combined_direction & Types.Direction.LEFT != 0
					and power_receiver.input_direction & Types.Direction.RIGHT == 0
				)
				or (
					combined_direction & Types.Direction.UP != 0
					and power_receiver.input_direction & Types.Direction.DOWN == 0
				)
			):
				continue
			# Otherwise add it to the path
			path.push_back(receiver)
	# We;ve done the receivers. Now, we check for any possible pipes so we can
	# keep traveling
	var movers := _find_neighbors_in(cellv, power_movers, direction)
	
	# Call this same function again from the new cell position for 
	# any pipe that found and travel from there, and return the result so long
	# as we did not visit it already
	# this is what makes the function recursive
	for mover in movers:
		if not mover in cells_travelled:
			path = _trace_path_from(mover, path)
		
	# Return the final array
	return path

# helper function for _trace_path_from function
func _find_neighbors_in(cellv: Vector2, collection: Dictionary, output_directions: int = 15) -> Array:
	var neighbors := []
	# For each of UP, DOWN, LEFT, and RIGHT
	for neighbor in Types.NEIGHBORS.keys():
		if neighbor & output_directions != 0:
			# calculate its map coordinate
			var key: Vector2 = cellv + Types.NEIGHBORS[neighbor]
			# if it is in the collection then add it
			if collection.has(key):
				neighbors.push_back(key)
	return neighbors

# compare a source to a target map position and return a direction integer
# that indicates the direction power is travelling in
func _combine_directions(receiver: Vector2, cellv: Vector2) -> int:
	if receiver.x < cellv.x:
		return Types.Direction.LEFT
	elif receiver.x > cellv.x:
		return Types.Direction.RIGHT
	elif receiver.y < cellv.y: 
		return Types.Direction.UP
	elif receiver.y > cellv.y:
		return Types.Direction.DOWN
	
	return 0

# For each system tick, calculate the power for each path and notify the components
func _on_systems_ticked(delta: float) -> void:
	# We're in a new tick, so clear all power received and start over.
	receivers_already_provided.clear()
	
	# For each power path,
	for path in paths:
		# Get the path's power source, which is the first element
		var power_source: PowerSource = power_sources[path[0]]
		
		# Get the effective power the source has to give. It cannot provide more than that amount
		var source_power := power_source.get_effective_power()
		
		# Keep a tally of how much power remains in the path.
		# It begins at the source power
		var remaining_power := source_power
		
		# A running tally of the power drawn by receivers in this path.
		var power_draw := 0.0
		
		# for each power receiver in the path
		# (elements of the path array after index 0)
		for cell in path.slice(1, path.size()-1):
			# If, for some reason, the element is not in our list, skip it.
			if not power_receivers.has(cell):
				continue
			
			# Get the actual power receiver component and calculate
			# how much power it desires.
			var power_receiver: PowerReceiver = power_receivers[cell]
			var power_required := power_receiver.get_effective_power()
			
			# Keep track of the total amount of power each
			# receiver has already received, in case of more than one power
			# source. Subtract the power the receiver still
			# needs so we don't draw more than necessary
			if receivers_already_provided.has(cell):
				var receiver_total: float = receivers_already_provided[cell]
				if receiver_total >= power_required:
					continue
				else:
					power_required -= receiver_total
			
			# Notify the receiver of the power available to it from this source
			power_receiver.emit_signal(
				"received_power", min(remaining_power, power_required), delta
			)
			
			# Add to the tally of the power required from this power source
			# We keep it clamped so that the machine cannot draw more power
			# than the machine can provide
			power_draw = min(source_power, power_draw + power_required)
			
			# Add to the running tally for this particular cell for any
			# furutre power source. Add it if it does not exist
			if not receivers_already_provided.has(cell):
				receivers_already_provided[cell] = min(remaining_power, power_required)
			else:
				receivers_already_provided[cell] += min(remaining_power, power_required)
			
			# Reduce the amount of power still available to other receivers by
			# the amount that _this_ receiver took. We clamp it to 0
			# so it cannot provide negative power
			remaining_power = max(0, remaining_power - power_required)
			
			# If you want to see the remaining power for each source printed
			# then uncomment this
			# print(remaining_power)
			
			# At this point, if we have no power left, then just break
			# Any other machine on the path will not be able
			# to update with 0 power anyway, so we can skip them.
			if remaining_power == 0:
				break
		# notify the power source of the amount of power that it provided.
		power_source.emit_signal("power_updated", power_draw, delta)


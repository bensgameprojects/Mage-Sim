extends TileMap


## Distance from the player when the mouse stops being able to interacty
const MAXIMUM_WORK_DISTANCE := 275.0

## When using `world_to_map()` or `map_to_world()`, `TileMap` reports values from the
## top-left corner of the tile.
## We might need an offset of like 16,16 or something but for now im going to
## leave it at 0,0
const POSITION_OFFSET := Vector2(16,16)
## Temporary variable to hold the active blueprint.
## For testing purposes, we hold it here until we build the inventory.
var _blueprint: BlueprintThing

# A copy of the scene_name so we can keep track of stuff
var _scene_name: String

## The simulation's thing tracker. We use its functions to know if a cell is available or it
## already has a thing.
var _thing_tracker: ThingTracker

## The ground tiles. We can check the position we're trying to put an thing down on
## to see if the mouse is over the tilemap.
var _ground: TileMap

# The YSort for anything the player can walk over, items and pipes maybe too
var _flat_things: YSort

## The player thing. We can use it to check the distance from the mouse to prevent
## the player from interacting with things that are too far away.
var _player: KinematicBody2D

var _player_facing_tile : Vector2

## Base time in seconds it takes to deconstruct something
const DECONSTRUCT_TIME := 1.5

## this variable keeps track of the current deconstruction target cell.
## If the mouse moves to another cell, we can abort the operation by checking against this
## value.
var _current_deconstruct_location := Vector2.ZERO

onready var _deconstruct_timer := $DeconstructTimer


func _ready() -> void:
	# Use the existing blueprint to act as a key for the thing scene, so we can instance
	# things given their blueprint
	Events.connect("place_blueprint", self, "_place_blueprint")

## Setup function sets the placer up with the data that it needs to function
## and adds any preplaced things to the tracker
func setup(scene_name: String, tracker: ThingTracker, ground: TileMap, flat_things: YSort, player: KinematicBody2D) -> void:
	# Use the function to initialize our private references
	# this makes refactoring easier because the ThingPlacer doesn't need
	# hard-coded paths to the ThingTracker, Groundtiles, and Player nodes
	_scene_name = scene_name
	_thing_tracker = tracker
	_ground = ground
	_player = player
	_flat_things = flat_things
	# for each child of thingPlacer, if it extended Thing, add it to the tracker
	# and ensure its position snaps to the grid
	for child in get_children():
		if child is Thing:
			# Get the world position of the child into map coordinates. These are
			# integer coordinates, which makes them ideal for repeatable
			# Dictionary keys, instead of the more rounding-error prone
			# decimal numbers of world coordinates.
			var map_position := world_to_map(child.global_position)
			
			# Report the Thing to the tracker to add it to the dictionary
			_thing_tracker.place_thing(child, map_position)

func _process(_delta: float) -> void:
	var has_placeable_blueprint: bool = _blueprint and _blueprint.placeable
	if has_placeable_blueprint:
		_move_blueprint_in_world(world_to_map(get_global_mouse_position()))
	# get the tile the player is looking at
	var new_active_tile = get_active_tile()
	# if it changed since last time then update
	if(_player_facing_tile != new_active_tile):
		# clear the old cell
		_clear_player_facing_thing(_player_facing_tile)
		# assign new cell
		_player_facing_tile = new_active_tile
		# get thing at the new tile and update display etc
		_player_facing_thing(_player_facing_tile)

func _unhandled_input(event: InputEvent) -> void:
	var global_mouse_position := get_global_mouse_position()
	# check whether we have a blueprint in hand (selected from ui) that can be placed
	var has_placeable_blueprint: bool = _blueprint and _blueprint.placeable
	# we check if the mouse is close enough to the Player node
	var is_close_to_player := (
		global_mouse_position.distance_to(_player.global_position) < MAXIMUM_WORK_DISTANCE
	)
	# get the coordinates of the cell the mouse is hovering over
	var cellv := world_to_map(global_mouse_position)
	# check if occupied
	var cell_is_occupied := _thing_tracker.is_cell_occupied(cellv)
	# check if there's a ground tile to place on
	var is_on_ground := _ground.get_cellv(cellv) == 0
	# If the user releases the deconstruct key or presses another mouse button,
	# we can abort. _abort_deconstruct safely disconnects the timer
	if event is InputEventMouseButton or event.is_action_released("deconstruct"):
		_abort_deconstruct()
	# left click to place an item
	if event.is_action_pressed("left_click"):
		if has_placeable_blueprint:
			if not cell_is_occupied and is_close_to_player and is_on_ground:
				# This line needs to get the building_id from somewhere and
				# pass it rather than the name of the building.
				if get_tree().get_nodes_in_group("InventoryUI")[0].deduct_cost_from_player_inv(BuildingList.get_recipe_by_id(BuildingList.get_thing_name_from(_blueprint))):
					_place_thing(cellv)
					_update_neighboring_flat_things(cellv)
				else: # Unable to afford building
					print("Can't afford building!")
				# deduct cost from inventory here perhaps?
	# press and hold "deconstruct" action (or G rn) to deconstruct an item
	elif event.is_action_pressed("deconstruct") and not has_placeable_blueprint:
		if cell_is_occupied and is_close_to_player:
			# we remove the thing that the mouse is hovering over
			_deconstruct(global_mouse_position, cellv)
	# this moves the blueprint to follow the mouse cursor	
	elif event is InputEventMouseMotion:
		if cellv != _current_deconstruct_location:
			_abort_deconstruct()
		if has_placeable_blueprint:
			_move_blueprint_in_world(cellv)
		else:
			_update_hover(cellv)
	# If user wants to cancel the placement we should remove the blueprint
	# note that the blueprint instances are shared in a library so we dont
	# want to free them
	elif event.is_action_pressed("ui_cancel") and _blueprint:
		_blueprint.queue_free()
		_blueprint = null
	elif event.is_action_pressed("ui_focus_next") and _blueprint:
		_blueprint.rotate_blueprint()

func _update_hover(cellv: Vector2) -> void:
	var is_close_to_player := (
		get_global_mouse_position().distance_to(_player.global_position)
		< MAXIMUM_WORK_DISTANCE
	)
	if _thing_tracker.is_cell_occupied(cellv) and is_close_to_player:
		_hover_thing(cellv)
	else:
		_clear_hover_thing(cellv)

func _hover_thing(cellv: Vector2) -> void:
	var thing = _thing_tracker.get_thing_at(cellv)
	Events.emit_signal("hovered_over_thing", thing)
	
func _clear_hover_thing(cellv: Vector2) -> void:
	Events.emit_signal("hovered_over_thing", null)

func _player_facing_thing(cellv: Vector2) -> void:
	var thing = _thing_tracker.get_thing_at(cellv)
	Events.emit_signal("player_facing_thing", thing)

func _clear_player_facing_thing(cellv: Vector2) -> void:
	Events.emit_signal("player_facing_thing", null)

func _place_blueprint(thing_id) -> void:
	var cellv := world_to_map(get_global_mouse_position())
	if _blueprint:
		_blueprint.queue_free()
	_blueprint = BuildingList.blueprints[thing_id].instance()
	add_child(_blueprint)
	_move_blueprint_in_world(cellv)

func _move_blueprint_in_world(cellv: Vector2) -> void:
	# snap the blueprints position to the mouse with an offset
	_blueprint.global_position = map_to_world(cellv) + POSITION_OFFSET
	
	# determine each of the placeable conditions
	var is_close_to_player := (
		get_global_mouse_position().distance_to(_player.global_position) < MAXIMUM_WORK_DISTANCE
	)
	var is_on_ground : bool = _ground.get_cellv(cellv) == 0
	var cell_is_occupied := _thing_tracker.is_cell_occupied(cellv)
	
	# Tint according to whether the current tile is valid or not.
	if not cell_is_occupied and is_close_to_player and is_on_ground:
		_blueprint.modulate = Color.white
	else:
		_blueprint.modulate = Color.red
	if _blueprint is PipeBlueprint:
		PipeBlueprint.set_sprite_for_direction(_blueprint.sprite, _get_powered_neighbors(cellv))
		
func _place_thing(cellv: Vector2) -> void:
	var thing_name := BuildingList.get_thing_name_from(_blueprint)
	# Use the blueprint prepared in _ready to instance a new thing
	var new_thing: Node2D = BuildingList.things[thing_name].instance()
	# check if pipe to get the required direction and sprite stuff
	# place it under the _flat_things ysort so its sorted correctly
	if _blueprint is PipeBlueprint:
		var directions := _get_powered_neighbors(cellv)
		_flat_things.add_child(new_thing)
		PipeBlueprint.set_sprite_for_direction(new_thing.sprite, directions)
	else:
		add_child(new_thing)
	
	# snap its position to the map, adding POSITION_OFFSET to thet the center of the grid cell
	new_thing.global_position = map_to_world(cellv) + POSITION_OFFSET
	
	new_thing._setup(_blueprint)
	
	_thing_tracker.place_thing(new_thing, cellv)

# Begin the deconstruction process at the current cell
func _deconstruct(event_position: Vector2, cellv: Vector2) -> void:
	# We connect tot the timer's 'timeout' signal. We pass in the targeted tile
	# as a bind argument and make sure that the signal disconnects after
	# emitting once using the CONNECT_ONESHOT flag. This is becase once the
	# signal has triggered, we do not want to have to disconnect manually.
	# Once the timer ends, the deconstruct operation ends.
	_deconstruct_timer.connect("timeout", self, "_finish_deconstruct", [cellv], CONNECT_ONESHOT)
	_deconstruct_timer.start(DECONSTRUCT_TIME)
	# save the location of the current deconstruction for reference
	_current_deconstruct_location = cellv

# if the timer goes off (confirmed deconstruction) then run this function
func _finish_deconstruct(cellv: Vector2) -> void:
	var thing := _thing_tracker.get_thing_at(cellv)
	_thing_tracker.remove_thing(cellv)
	# update da pipes
	_update_neighboring_flat_things(cellv)
	# refund the build cost of thing to the player's inventory HERE!
	# we might want to check that the deconstruct thing is a building vs something else
	get_tree().get_nodes_in_group("InventoryUI")[0].refund_cost_to_player_inv(BuildingList.get_recipe_by_id(BuildingList.get_thing_name_from(thing)))
	# or if the deconstruct operation causes a gatherable item to drop, then do that
	# instead


# Disconnect from the timer if connected and stop it from continuing
# to prevent deconstruction from completing
func _abort_deconstruct() -> void:
	if _deconstruct_timer.is_connected("timeout", self, "_finish_deconstruct"):
		_deconstruct_timer.disconnect("timeout", self, "_finish_deconstruct")
	_deconstruct_timer.stop()

# Returns a bit-wise integer based on whether the nearby objects can carry power
func _get_powered_neighbors(cellv: Vector2) -> int: 
	# begin with a blank direction of 0
	var direction := 0
	
	# loop over each neighboring direction from Types.NEIGHBORS
	for neighbor in Types.NEIGHBORS.keys():
		# calculate the neighbor cell's corrds
		var key: Vector2 = cellv + Types.NEIGHBORS[neighbor]
		# get the thing in the cell if there is one.
		if _thing_tracker.is_cell_occupied(key):
			var thing: Node = _thing_tracker.get_thing_at(key)
			
			# if the thing is part of any of the power groups
			if (
				thing.is_in_group(Types.POWER_MOVERS)
				or thing.is_in_group(Types.POWER_RECEIVERS)
				or thing.is_in_group(Types.POWER_SOURCES)
			):
				# Combine the number with the bitwise OR operator
				direction |= neighbor
	# return the combined direction
	return direction

# Looks at each of the neighboring tiles and updates each of them to use
# the correct graphcics based on their own neighbors.
func _update_neighboring_flat_things(cellv: Vector2) -> void:
	# For each neighboring tile,
	for neighbor in Types.NEIGHBORS.keys():
		# We get the thing, if there is one
		var key: Vector2 = cellv + Types.NEIGHBORS[neighbor]
		var object = _thing_tracker.get_thing_at(key)
		
		# If it's a pipe, we have that pipe update its graphics to connect to the new pipe
		if object and object is PipeThing:
			var tile_directions := _get_powered_neighbors(key)
			PipeBlueprint.set_sprite_for_direction(object.sprite, tile_directions)

func get_active_tile() -> Vector2:
	var offset = Vector2(32,32)
	# returns cellv in front of the player in the direction they are facing.
	return world_to_map(_player.global_position + _player.direction_vector * offset)


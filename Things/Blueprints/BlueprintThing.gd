class_name BlueprintThing
extends Node2D


## Whether the player can place this object in the world. For example, a lumber axe.
## should not be 'placed' like a machine.
export var placeable := true

onready var power_direction := find_node("PowerDirection")

func rotate_blueprint() -> void:
	if not power_direction:
		return
	
	# Get the current directions flags.
	var directions: int = power_direction.output_directions
	# Initialize the new direction value at 0.
	var new_directions := 0
	
	# Below, we check for each Types.Direction against the directions value
	# If a direction is included in the directions flag,
	# we rotate it 90 degrees using the bitwise pipe operator '|'.
	# LEFT becomes UP
	if directions & Types.Direction.LEFT != 0:
		new_directions |= Types.Direction.UP
	
	# UP becomes RIGHT
	if directions & Types.Direction.UP != 0:
		new_directions |= Types.Direction.RIGHT
	
	# RIGHT becomes DOWN
	if directions & Types.Direction.RIGHT != 0:
		new_directions |= Types.Direction.DOWN
	
	# DOWN becomes LEFT
	if directions & Types.Direction.DOWN != 0:
		new_directions |= Types.Direction.LEFT
	
	# set the new direction, which should set the arrow sprites
	power_direction.output_directions = new_directions

# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = 9


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

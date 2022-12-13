extends Node2D


# Arrows from the sprite sheet in a dictionary keyed with a description
# of which way the arrow faces
const REGIONS := {
	"Up": Rect2(0,0,32,32),
	"Down": Rect2(64,0,32,32),
	"Right": Rect2(32,0,32,32),
	"Left": Rect2(96,0,32,32)
}

# A set of flags based on our Types.Direction enum. Allows you to choose the
# output direction(s) for the entity.

export (Types.Direction, FLAGS) var output_directions: int = 15 setget _set_output_directions

# References to the scene's four sprite nodes.
onready var west := $W
onready var north := $N
onready var east := $E
onready var south := $S

# Compares the output directions to the Types.Direction enum and assigns
# the correct arrow texture to it. Uses bitwise and '&'
func set_indicators() -> void:
	if output_directions & Types.Direction.LEFT != 0:
		# point outward
		west.region_rect = REGIONS.Left
	else:
		# point inwards instead
		west.region_rect = REGIONS.Right
	if output_directions & Types.Direction.RIGHT != 0:
		east.region_rect = REGIONS.Right
	else:
		east.region_rect = REGIONS.Left
	if output_directions & Types.Direction.UP != 0:
		north.region_rect = REGIONS.Up
	else:
		north.region_rect = REGIONS.Down
	if output_directions & Types.Direction.DOWN != 0:
		south.region_rect = REGIONS.Down
	else:
		south.region_rect = REGIONS.Up

# The setter for the blueprint's direction value.
func _set_output_directions(value: int) -> void:
	output_directions = value
	# wait until the blueprint has appeared in the scene tree at least once
	# We must do this as setter get called _before_ the node is in
	# the scene tree, meaning the sprites are not yet in their
	# onready variables.
	if not is_inside_tree():
		yield(self, "ready")
	
	# Set the sprite graphics according to the direction value.
	set_indicators()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

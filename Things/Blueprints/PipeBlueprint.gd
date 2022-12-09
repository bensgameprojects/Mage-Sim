class_name PipeBlueprint
extends BlueprintThing

# For Reference: Types.Direction = { RIGHT = 1, DOWN = 2, LEFT = 4, UP = 8 }
# Constant dictionary that holds the sprite region information for the pipe's
# spritesheet. The numbers used as keys represent combinations of the direction values
# we wrote in 'Types.Directions'. We have values for all directions to be fail-safe.
const DIRECTIONS_DATA := {
	1: Rect2(32, 0, 32, 32), # RIGHT
	4: Rect2(32, 0, 32, 32), # LEFT
	5: Rect2(32, 0, 32, 32),  # LEFT AND RIGHT
	2: Rect2(0,0,32,32), # DOWN
	8: Rect2(0,0,32,32), # UP
	10: Rect2(0,0,32,32), # UP AND DOWN
	15: Rect2(64,0,32,32), # ALL DIRECTIONS
	6: Rect2(160,0,32,32), # LEFT AND DOWN
	12: Rect2(96, 0, 32, 32), #LEFT AND UP
	3: Rect2(192, 0, 32, 32), # RIGHT AND DOWN
	9: Rect2(128, 0, 32, 32), # UP AND RIGHT
	7: Rect2(320, 0, 32, 32), # LEFT DOWN AND RIGHT
	14: Rect2(224, 0, 32, 32), # UP LEFT AND DOWN
	13: Rect2(256, 0, 32, 32), # UP LEFT AND RIGHT
	11: Rect2(288, 0, 32, 32), # UP DOWN AND RIGHT
}

onready var sprite = $Sprite
# Helper function to set the sprite based on the provided combined value for 'directions'
# in which there are neighboring pipes or machines to connect pipes to
static func set_sprite_for_direction(sprite: Sprite, directions: int) -> void:
	sprite.region_rect = get_region_for_direction(directions)
	
# static function to get an appropriate value from 'DIRECITONS_DATA'.
static func get_region_for_direction(directions: int) -> Rect2:
	# if the 'directions' value is invalid, defauls to '10', which is UP AND DOWN
	if not DIRECTIONS_DATA.has(directions):
		directions = 10
	
	return DIRECTIONS_DATA[directions]
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

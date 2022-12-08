class_name Bullet
extends Node2D

var velocity = Vector2.ZERO
var speed
var initial_position
var initial_direction
var knockback
var knockback_vector
var damage

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GroupConstants.BULLET_GROUP)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

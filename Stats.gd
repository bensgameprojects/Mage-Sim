extends Node2D

export var KNOCKBACK_FRICTION = 30
export var KNOCKBACK_SPEED = 420

export var max_health = 1
onready var health = max_health setget set_health

signal no_health()

# whenever health variable is set it will use this function to set it
func set_health(value):
	health = value
	if health <= 0:
		emit_signal("no_health")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

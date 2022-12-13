class_name Entity
extends KinematicBody2D


var state
var velocity = Vector2.ZERO
var input_vector = Vector2.ZERO
var on_cooldown = false
var bullet_start_position
var bullet_direction
# init rng
var statePickerRNG = RandomNumberGenerator.new()
#default values, can change per enemy in their individual script
export var MOVE_ACCELERATION = 20
export var MOVE_FRICTION = 160
export var MOVE_MAX_SPEED = 80
export var SPRINT_MAX_SPEED = 120
export var SPRINT_ACCELERATION = 40
export var KNOCKBACK_FRICTION = 30
export var KNOCKBACK_SPEED = 420
export var COOLDOWN_REDUCTION = 0
# invincibility time in seconds
export var HIT_INVINCIBILITY_TIME = 0.5
export var ROLL_INVINCIBILITY_TIME = 0.6
export(int) var max_health = 1 setget set_max_health
#cant be an onready because set_max_health is called on above line
# which uses the health variable
#so we need to use a _ready func
var health = max_health setget set_health

signal no_health()
signal health_changed(value)
signal max_health_changed(value)

func _ready():
	self.health = max_health

func set_max_health(value):
	# dont allow max_health to be < 1
	max_health = max(value, 1)
	# cap the current health to max health in case it changes
	self.health = min(health, max_health)
	emit_signal("max_health_changed", max_health)

# whenever health variable is set it will use this function to set it
func set_health(value):
	# dont allow health to exceed maximum
	health = clamp(value, 0, max_health)
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

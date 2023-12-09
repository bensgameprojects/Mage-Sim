extends Node2D

# this will be autoloaded so that the players stats/state/position etc
# can all be accessed from one spot easily.
# Saving the players' stats can be implemented here also.
# Choosing not to use a resource because it will be autoloaded once
# and can be saved/loaded as a json instead to avoid security issues.
var state
################################
#  CURRENT SELECTED ABILITIES  #
################################
var left_click_ability: PackedScene
var right_click_ability: PackedScene
var left_click_ability_id: String
var right_click_ability_id: String

################################
# MOVEMENT AND KNOCKBACK STATS #
################################

export var MOVE_ACCELERATION := 20.0
export var MOVE_FRICTION := 160.0
export var MOVE_MAX_SPEED := 80.0
export var SPRINT_MAX_SPEED := 120.0
export var SPRINT_ACCELERATION := 40.0
export var KNOCKBACK_FRICTION := 20.0
export var KNOCKBACK_SPEED := 200.0
# 0 is no knockback resistance, 1 is completely resistant to knockback
export var KNOCKBACK_RESISTANCE := 0.0

# this gets updated each physics process with the player's gloabl_position
# in player.gd
var player_position := Vector2.ZERO
# this gets updated when a knockback event happens
var knockback_vector := Vector2.ZERO

##############################
#           STATS            #
##############################
export(int) var max_health = 5 setget set_max_health

var health = max_health setget set_health

# Percentage of how much cooldown reduction you get
# 0 is a 0% cooldown_reduction 1 is 100% reduced
export var COOLDOWN_REDUCTION := 0.0 setget set_cooldown_reduction
# base cooldown time in seconds
export var COOLDOWN_TIME = 1.5 setget set_cooldown_time

# invincibility time in seconds
export var HIT_INVINCIBILITY_TIME = 0.5 setget set_hit_invincibility_time

################################
#   CURRENT STATUS EFFECTS     #
################################

var is_sprint = false

var on_cooldown = false
var cooldown_timer

var is_invincible = false setget set_invincible
var invincibility_timer

var is_stunned = false
var stun_timer

var is_frozen = false
var freeze_timer

var is_burning = false
var burn_timer

var is_regening = false

var is_invisible = false
var invis_timer

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
const damage_effect = preload("res://UI/DamageValue.tscn")
const regen_component = preload("res://Abilities/Bullets/Regen.tscn")
signal no_health()
signal health_changed(value)
signal max_health_changed(value)
signal invincibility_changed(value)

func _ready():
	cooldown_timer = Timer.new()
	add_child(cooldown_timer)
	cooldown_timer.connect("timeout", self, "_on_cooldown_timer_timeout")
	stun_timer = Timer.new()
	add_child(stun_timer)
	stun_timer.connect("timeout", self, "remove_stun")
	invincibility_timer = Timer.new()
	add_child(invincibility_timer)
	invincibility_timer.connect("timeout", self, "_on_invincibility_timer_timeout")
	Events.connect("respawn_player", self, "reset_health")

func reset_health():
	self.health = max_health

func set_cooldown_reduction(value):
	COOLDOWN_REDUCTION = clamp(value, 0, 1)

func set_cooldown_time(value):
	COOLDOWN_TIME = max(0, value)

func set_hit_invincibility_time(value):
	HIT_INVINCIBILITY_TIME = max(0, value)

func set_invincible(value: bool):
	is_invincible = value
	emit_signal("invincibility_changed", value)

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

func take_damage(value, damage_type):
	health = clamp(health - value, 0, max_health)
	emit_signal("health_changed", health)
	set_invincibility()
	if health <= 0:
		emit_signal("no_health")
	Events.emit_signal("display_value", value, damage_type, player_position)

func heal(value):
	health = clamp(health + value, 0, max_health)
	emit_signal("health_changed", health)
	Events.emit_signal("display_value", value, "HEAL", player_position)

func apply_knockback(source_position: Vector2, knockback_speed):
	KNOCKBACK_SPEED = knockback_speed * (1 - KNOCKBACK_RESISTANCE)
	knockback_vector = source_position.direction_to(player_position) * KNOCKBACK_SPEED

# check if we're on cool down or not
func is_on_cooldown():
	return on_cooldown

# After using a spell this will turn on the cooldown
# uses the COOLDOWN_TIME and COOLDOWN_REDUCTION script variables
func set_cooldown_on():
	on_cooldown = true
	cooldown_timer.start(max(0, COOLDOWN_TIME * (1 - COOLDOWN_REDUCTION)))
	
func _on_cooldown_timer_timeout():
	cooldown_timer.stop()
	on_cooldown = false

func set_invincibility():
	invincibility_timer.start(HIT_INVINCIBILITY_TIME)
	is_invincible = true
	emit_signal("invincibility_changed", true)

func _on_invincibility_timer_timeout():
	is_invincible = false
	invincibility_timer.stop()
	emit_signal("invincibility_changed", false)

# For now we will just modulate the color of the stunned as an indicator
func apply_stun(duration):
	if not is_stunned:
		is_stunned = true
		stun_timer.start(duration)
		self.modulate = Color.yellow
	else:
		stun_timer.start(max(stun_timer.time_left, duration))

func remove_stun():
	if stun_timer != null:
		stun_timer.stop()
	is_stunned = false
	self.modulate = Color.white

# each time the regen timer goes off this happens
func _apply_regen_tick(regen_amount, damage_type):
	if regen_amount > 0:
		heal(regen_amount)
	if regen_amount < 0:
		take_damage(-1*regen_amount, damage_type)

func apply_regen_spell(regen_value: int, regen_duration: float, type: String):
	# immediate tick when the spell is cast
	_apply_regen_tick(regen_value, type)
	var new_regen = regen_component.instance()
	new_regen.setup(regen_value, regen_duration, type)
	# connect to the regen component to take damage/regain health
	new_regen.connect("regen_tick", self, "_apply_regen_tick")
	add_child(new_regen)

# Returns packed scene for the corresponding ability
func load_ability(ability_name:String):
	# build the path to the ability tscn from the name
	var path = "res://Abilities/Abilities/" + ability_name + ".tscn"
	# load it
	# return loaded_ability
	return load(path)

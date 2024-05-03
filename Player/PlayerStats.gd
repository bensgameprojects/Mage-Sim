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
export var BASE_MAX_HEALTH := 5
export var MOVE_ACCELERATION := 20.0
export var MOVE_FRICTION := 160.0

export var BASE_MOVE_MAX_SPEED := 80.0
export var BASE_SPRINT_MAX_SPEED := 120.0

export var SPRINT_ACCELERATION := 40.0
export var KNOCKBACK_FRICTION := 20.0
export var KNOCKBACK_SPEED := 200.0
# 0 is no knockback resistance, 1 is completely resistant to knockback
export var KNOCKBACK_RESISTANCE := 0.0

# these are updated computed values from the statblock
# whenever they are changed the signal is emitted to update these
# so that physics process doesnt have to compute them all the time.
var SPRINT_MAX_SPEED := 120.0
var MOVE_MAX_SPEED := 80.0
# this gets updated each physics process with the player's gloabl_position
# in player.gd
var player_position := Vector2.ZERO
# this gets updated when a knockback event happens
var knockback_vector := Vector2.ZERO

##############################
#           STATS            #
##############################

var stat_block = StatBlock.new()
# current health var
var health = 1

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
	# so we dont need to compute these every time
	stat_block.max_health.connect("stat_changed", self, "set_max_health")
	stat_block.move_speed.connect("stat_changed", self, "set_move_speed")
	stat_block.sprint_speed.connect("stat_changed", self, "set_sprint_speed")
	stat_block.max_health.base = BASE_MAX_HEALTH
	stat_block.move_speed.base = BASE_MOVE_MAX_SPEED
	stat_block.sprint_speed.base = BASE_SPRINT_MAX_SPEED
	reset_health()

func reset_health():
	self.health = stat_block.max_health.compute()

func set_cooldown_time(value):
	COOLDOWN_TIME = max(0, value)

func set_hit_invincibility_time(value):
	HIT_INVINCIBILITY_TIME = max(0, value)

func set_invincible(value: bool):
	is_invincible = value
	emit_signal("invincibility_changed", value)

func set_max_health(value):
	# dont allow max_health to be < 1
	#max_health = max(value, 1)
	# cap the current health to max health in case it changes
	self.health = min(health, value)
	emit_signal("max_health_changed", value)

func set_move_speed(value):
	MOVE_MAX_SPEED = max(0, value)

func set_sprint_speed(value):
	SPRINT_MAX_SPEED = max(0, value)

# whenever health variable is set it will use this function to set it
func set_health(value):
	# dont allow health to exceed maximum
	health = clamp(value, 0, stat_block.max_health.compute())
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func take_damage(value, damage_type):
	# resistances are from 0 to 100% resisted any higher is capped
	# defense is resistance to unaspected.
	# anything lower is counted as extra damage
	# value is always rounded.
	match damage_type:
		"FIRE":
			value = int(round(value * (100 - min(stat_block.fire_resist.compute(),100))/100))
		"WATER":
			value = int(round(value * (100 - min(stat_block.water_resist.compute(),100))/100))
		"EARTH":
			value = int(round(value * (100 - min(stat_block.earth_resist.compute(),100))/100))
		"WIND":
			value = int(round(value * (100 - min(stat_block.wind_resist.compute(),100))/100))
		_:
			value = int(round(value * (100 - min(stat_block.defense.compute(),100))/100))
	health = clamp(health - value, 0, stat_block.max_health.compute())
	emit_signal("health_changed", health)
	set_invincibility()
	if health <= 0:
		emit_signal("no_health")
	Events.emit_signal("display_value", value, damage_type, player_position)

func heal(value):
	health = clamp(health + value, 0, stat_block.max_health.compute())
	emit_signal("health_changed", health)
	Events.emit_signal("display_value", value, "HEAL", player_position)

func apply_knockback(source_position: Vector2, knockback_speed):
	KNOCKBACK_SPEED = knockback_speed * (100 - min(stat_block.knockback_resist.compute(),100))/100
	knockback_vector = source_position.direction_to(player_position) * KNOCKBACK_SPEED

# check if we're on cool down or not
func is_on_cooldown():
	return on_cooldown

# After using a spell this will turn on the cooldown
# uses the COOLDOWN_TIME and COOLDOWN_REDUCTION script variables
func set_cooldown_on():
	on_cooldown = true
	cooldown_timer.start(max(0, COOLDOWN_TIME * (100 - min(stat_block.cooldown_reduction.compute(),100))/100))

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
	duration = duration * stat_block.stun_resist.compute()/100
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
	# add heal potency.
	new_regen.setup(regen_value*max(stat_block.heal_potency.compute(),0), regen_duration, type)
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

class_name Entity
extends KinematicBody2D

# You MUST call setup_entity() and give it the required params
# To use the entity. Currently it's just for assigning the cooldown_timer


var state
var velocity = Vector2.ZERO
var input_vector = Vector2.ZERO
var on_cooldown = false
var is_invincible = false
var is_sprint = false
var is_stunned = false
var is_frozen = false
var is_burning = false
var is_regening = false
var is_invisible = false

# init rng
var statePickerRNG = RandomNumberGenerator.new()
#default values, can change per enemy in their individual script
export(float) var MOVE_ACCELERATION = 20
export(float) var MOVE_FRICTION = 160
export(float) var MOVE_MAX_SPEED = 80
export(float) var SPRINT_MAX_SPEED = 120
export(float) var SPRINT_ACCELERATION = 40
export(float) var KNOCKBACK_FRICTION = 20
export(float) var KNOCKBACK_SPEED = 200
# 0 is no knockback resistance, 1 is completely resistant to knockback
export(float) var KNOCKBACK_RESISTANCE = 0.0
# Percentage of how much cooldown reduction you get
# 0 is a 0% cooldown_reduction 100 is 100% reduced
export(float) var COOLDOWN_REDUCTION = 0.0 setget set_cooldown_reduction
# base cooldown time in seconds
export(float) var COOLDOWN_TIME = 1.5 setget set_cooldown_time
# invincibility time in seconds
export(float) var HIT_INVINCIBILITY_TIME = 0.5 setget set_hit_invincibility_time
export(int) var max_health = 1 setget set_max_health
#cant be an onready because set_max_health is called on above line
# which uses the health variable
#so we need to use a _ready func
var health = max_health setget set_health
var invincibility_timer
var knockback_vector := Vector2.ZERO
var cooldown_timer
var stun_timer
var freeze_timer
var burn_timer
var invis_timer

var hurtbox

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
const regen_component = preload("res://Abilities/Bullets/Regen.tscn")

signal no_health()
signal health_changed(value)
signal max_health_changed(value)

func _ready():
	cooldown_timer = Timer.new()
	add_child(cooldown_timer)
	cooldown_timer.connect("timeout", self, "_on_cooldown_timer_timeout")
	invincibility_timer = Timer.new()
	add_child(invincibility_timer)
	invincibility_timer.connect("timeout", self, "_on_invincibility_timer_timeout")
	self.connect("no_health", self, "_on_no_health")
	hurtbox = get_hurtbox()
	if hurtbox != null:
		hurtbox.connect("hit_by", self, "_hit_by_spell")

func get_hurtbox():
	for child in get_children():
		if child.name == "Hurtbox":
			return child
	return null

func set_cooldown_reduction(value :float):
	COOLDOWN_REDUCTION = clamp(value, 0, 100)

func set_cooldown_time(value :float):
	COOLDOWN_TIME = max(0, value)

func set_hit_invincibility_time(value :float):
	HIT_INVINCIBILITY_TIME = max(0, value)

func set_max_health(value :float):
	# dont allow max_health to be < 1
	max_health = max(value, 1)
	# cap the current health to max health in case it changes
	self.health = min(health, max_health)
	emit_signal("max_health_changed", max_health)

# whenever health variable is set it will use this function to set it
func set_health(value :float):
	# dont allow health to exceed maximum
	health = clamp(value, 0, max_health)
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func take_damage(value :float, damage_type: String):
	health = clamp(health - value, 0, max_health)
	emit_signal("health_changed", health)
	set_invincibility()
	if health <= 0:
		emit_signal("no_health")
	Events.emit_signal("display_value", value, damage_type, self.global_position)

func apply_knockback(source_position: Vector2, knockback_speed):
	KNOCKBACK_SPEED = knockback_speed * (1 - KNOCKBACK_RESISTANCE)
	knockback_vector = source_position.direction_to(self.global_position) * KNOCKBACK_SPEED

# Returns packed scene for the corresponding ability
func load_ability(ability_name):
	# build the path to the ability tscn from the name
	var path = "res://Abilities/Abilities/" + ability_name + ".tscn"
	# load it
	# return loaded_ability
	return load(path)

# This function will check if we are on cooldown
# if not, then use the spell and return true
# else return false (no spell cast)
func use_ability_if_able(spell,initial_position: Vector2, initial_direction: Vector2, caster) -> bool:
	if not is_on_cooldown() and not is_stunned:
		use_ability(spell, initial_position, initial_direction, caster)
		return true
	return false

# input is a packed scene that will be instanced
# and its setup function will be executed.
func use_ability(spell, initial_position: Vector2, initial_direction: Vector2, caster) -> void:
	#emit signal to spawn the spell which is caught by whoever is gonna be the parent
	#currently its the spawnhandler node
	Events.emit_signal("spawn_spell", spell, initial_position, initial_direction, caster)
	set_cooldown_on()

func move_entity(direction_vector: Vector2) -> void:
	if is_sprint:
		velocity = velocity.move_toward(direction_vector * SPRINT_MAX_SPEED, SPRINT_ACCELERATION)
	else:
		velocity = velocity.move_toward(direction_vector * MOVE_MAX_SPEED, MOVE_ACCELERATION)
	if(direction_vector == Vector2.ZERO):
		velocity = velocity.move_toward(Vector2.ZERO, MOVE_FRICTION)

# check if we're on cool down or not
func is_on_cooldown():
	return on_cooldown

# After using a spell this will turn on the cooldown
# uses the COOLDOWN_TIME and COOLDOWN_REDUCTION script variables
func set_cooldown_on():
	on_cooldown = true
	cooldown_timer.start(max(0, COOLDOWN_TIME * (1 - COOLDOWN_REDUCTION / 100)))
	
func _on_cooldown_timer_timeout():
	cooldown_timer.stop()
	on_cooldown = false

func set_invincibility():
	invincibility_timer.start(HIT_INVINCIBILITY_TIME)
	hurtbox.set_invincibility(true)
	is_invincible = true

func _on_invincibility_timer_timeout():
	hurtbox.set_invincibility(false)
	is_invincible = false
	invincibility_timer.stop()

# Basic death function
# Overwrite if you want something else. 
func _on_no_health():
	Events.emit_signal("death_effect", self.global_position)
	queue_free()

# For now we will just modulate the color of the stunned as an indicator
func apply_stun(duration):
	if stun_timer == null:
		stun_timer = Timer.new()
		add_child(stun_timer)
		stun_timer.connect("timeout", self, "remove_stun")
	if not is_stunned:
		is_stunned = true
		stun_timer.start(duration)
		self.modulate = Color.yellow
	else:
		# you're already stunned get locked up noob hehe
		# choose the max between your current stun amount and 
		# how much we are trying to apply
		stun_timer.start(max(stun_timer.time_left, duration))

func remove_stun():
	if stun_timer != null:
		stun_timer.stop()
	is_stunned = false
	self.modulate = Color.white

func heal(value):
	health = clamp(health + value, 0, max_health)
	Events.emit_signal("display_value", value, "HEAL", self.global_position)

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

# what happens when an entity is hit by something
func _hit_by_spell(spell_info: Dictionary, given_position: Vector2):
	var element_type := ""
	if spell_info.has("element"):
		element_type = spell_info["element"]
	# apply any keywords we know
	if spell_info.has("damage"):
		take_damage(spell_info["damage"], element_type)
	if spell_info.has("stun_duration"):
		apply_stun(spell_info["stun_duration"])
	if spell_info.has("add_health"):
		heal(spell_info["add_health"])
	if spell_info.has("knockback_speed"):
		apply_knockback(given_position, spell_info["knockback_speed"])
	if spell_info.has_all(["regen", "regen_duration"]):
		apply_regen_spell(spell_info["regen"], spell_info["regen_duration"], element_type)

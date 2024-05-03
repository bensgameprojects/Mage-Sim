class_name Player
#extends Entity
extends KinematicBody2D
# Member variable declaration

# States for the state machine
enum {
	MOVE,
	CAST
}

# inits when the ready function is ready
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var cameraHandler = $CameraHandler
onready var hurtbox = $Hurtbox

var input_vector := Vector2.ZERO
var spell_direction := Vector2.ZERO
var state = MOVE
var velocity := Vector2.ZERO
# Called when the node enters the scene tree for the first time. (init)
func _ready():
	# activate the animation tree.
	animationTree.active = true
	PlayerStats.player_position = self.global_position
	# add the player to the player group
	add_to_group(GroupConstants.PLAYER_GROUP)
	# using some signals for ui to update action
	# calling for player respawn stuff
	# spawning items on the player
	Events.connect("update_action", self, "_update_action")
	Events.connect("respawn_player", self, "_on_player_respawn")
	PlayerStats.connect("no_health", self, "_on_no_health")
	PlayerStats.connect("invincibility_changed", self, "_on_invincibility_changed")
	hurtbox.connect("hit_by", self, "_hit_by_spell")


func _unhandled_input(event):
	if (event.is_action("ui_left") or event.is_action("ui_right") 
	or event.is_action("ui_up") or event.is_action("ui_down")):
		input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	elif event.is_action_pressed("sprint"):
		PlayerStats.is_sprint = true
	elif event.is_action_released("sprint"):
		PlayerStats.is_sprint = false
	elif event.is_action_pressed("left_click"):
		var mouse_pos = get_global_mouse_position()
		if use_ability_if_able(PlayerStats.left_click_ability, self.global_position, mouse_pos):
			spell_direction = self.global_position.direction_to(mouse_pos)
			state = CAST

# Called whenever physics tick happens, delta unlocks movement from framerate
func _physics_process(delta):
	# update the player stats position for everyone else's reference
	PlayerStats.player_position = self.position
	# forces only 1 state to be running at a time
	match state:
		MOVE:
			move_state(delta)
		CAST:
			cast_state(delta)
		#default
		_:
			move_state(delta)
	# set the movement and collision stuff, makes us sticky to collision polygons
	# move_and_collide(velocity * delta)
	# using move and slide so we can slide against walls, doesnt multiply by delta
	# move and slide will handle it for us
	# knockback_vector gets set by attacks
	PlayerStats.knockback_vector = move_and_slide(PlayerStats.knockback_vector)
	PlayerStats.knockback_vector = PlayerStats.knockback_vector.move_toward(Vector2.ZERO, PlayerStats.KNOCKBACK_FRICTION)
	# the move state handles the velocity calcs
	velocity = move_and_slide(velocity)

func move_state(_delta):
	if PlayerStats.is_stunned:
		velocity = Vector2.ZERO
	else:
	#	print("in move state")
		# apply acceleration/decceleration, multiply by delta which is the tick rate (1/60 usually)
		if input_vector != Vector2.ZERO:
			#only update the blend position while moving so it will stop and face the right direction
			animationTree.set("parameters/Idle/blend_position", input_vector)
			animationTree.set("parameters/Run/blend_position", input_vector)
			animationTree.set("parameters/Attack/blend_position", input_vector)
			animationTree.set("parameters/Roll/blend_position", input_vector)
			# change state
			animationState.travel("Run")
			#speeding up/hitting max speed.
			if PlayerStats.is_sprint:
				velocity = velocity.move_toward(input_vector * PlayerStats.SPRINT_MAX_SPEED, PlayerStats.SPRINT_ACCELERATION)
			else:
				velocity = velocity.move_toward(input_vector * PlayerStats.MOVE_MAX_SPEED, PlayerStats.MOVE_ACCELERATION)
			# outdated method
			#velocity += input_vector * ACCELERATION * delta
			#velocity = velocity.clamped(MAX_SPEED * delta)
		else:
			animationState.travel("Idle")
			# slowing down with friction
			velocity = velocity.move_toward(Vector2.ZERO, PlayerStats.MOVE_FRICTION)

func attack_state(_delta):
#	print("in attack state")
	# reset your velocity
	velocity = Vector2.ZERO
	#give u a little bit of invincibility frames
	PlayerStats.set_invincibility()
	# move to attack state and play animation
	animationState.travel("Attack")
	# at the end of the animation it will call attack_animation_finished()

func attack_animation_finished():
#	print("attack finished")
	state = MOVE

func roll_animation_finished():
#	print("roll finished")
	if PlayerStats.is_sprint:
		velocity.limit_length(PlayerStats.SPRINT_MAX_SPEED)
	else:
		velocity.limit_length(PlayerStats.MOVE_MAX_SPEED)
	state = MOVE

func attach_camera(camera_path):
	cameraHandler.set("remote_path", camera_path)

func detach_camera():
	cameraHandler.set("remote_path", "")


func cast_state(_delta):
	animationTree.set("parameters/Idle/blend_position", spell_direction)
	animationTree.set("parameters/Run/blend_position", spell_direction)
	animationTree.set("parameters/Attack/blend_position", spell_direction)
	animationTree.set("parameters/Roll/blend_position", spell_direction)
	animationState.travel("Attack")
	velocity = velocity.move_toward(Vector2.ZERO, PlayerStats.MOVE_FRICTION)

func create_on_hit_effect():
	hurtbox.create_hit_effect()

# overwrite the _on_no_health() function for the player
# so they dont queue_free because we need the player
# as a reference for the simulation.
func _on_no_health():
	Events.emit_signal("death_effect", self.global_position)
	self.visible = false
	PlayerStats.is_stunned = true
	PlayerStats.is_invincible = true
	# wait until the crazy dies down and then emit signal
	Events.emit_signal("player_died")

func _on_invincibility_changed(value):
	hurtbox.set_invincibility(value)

func _on_player_respawn():
	self.visible = true
	PlayerStats.is_stunned = false
	PlayerStats.is_invincible = false

# This function will check if we are on cooldown
# if not, then use the spell and return true
# else return false (no spell cast)
# overwrites the parents version to deduct recipe cost
func use_ability_if_able(spell,initial_position: Vector2, global_mouse_pos: Vector2) -> bool:
	if PlayerStats.is_stunned:
		Events.emit_signal("notify_player", NotificationTypes.Notifications.IS_STUNNED, {"spell_id" : PlayerStats.left_click_ability_id, "time_left" : PlayerStats.stun_timer.time_left})
#		Events.emit_signal("notify_player", "Unable to cast " + left_click_ability_id + "! Reason: Stunned")
		return false
	elif PlayerStats.is_on_cooldown():
		Events.emit_signal("notify_player", NotificationTypes.Notifications.ON_GCD_COOLDOWN, {"spell_id" : PlayerStats.left_click_ability_id,"time_left" : PlayerStats.cooldown_timer.time_left})
#		Events.emit_signal("notify_player", "Unable to cast " + left_click_ability_id + "! Spell on cooldown for %.2f more seconds." % cooldown_timer.time_left)
		return false
	else: # We can try to cast if we have the stuff
		# Deduct the cost of the recipe if there is one
		var recipe = RecipeList.get_recipe_by_id(PlayerStats.left_click_ability_id)
		if deduct_cost_from_player_inv(recipe):
			use_ability(spell, initial_position, global_mouse_pos, self)
			return true
		else:
			Events.emit_signal("notify_player", NotificationTypes.Notifications.CANT_AFFORD_SPELL, {"spell_id" : PlayerStats.left_click_ability_id})
#			Events.emit_signal("notify_player", "Unable to afford " + left_click_ability_id + "! Costs " + RecipeList.build_requirements_string(left_click_ability_id) + ".")
	return false

func use_ability(spell, initial_position: Vector2, global_mouse_pos: Vector2, caster) -> void:
	#emit signal to spawn the spell which is caught by whoever is gonna be the parent
	#currently its the spawnhandler node
	Events.emit_signal("spawn_spell", spell, initial_position, global_mouse_pos, caster)
	PlayerStats.set_cooldown_on()

# returns true if able to pay the cost
# and returns false if unable to afford the cost.
# returns true if the recipe is empty/null or doesnt have the required keys.
func deduct_cost_from_player_inv(recipe) -> bool:
	if recipe == null or recipe.empty() or not recipe.has_all(["component_ids", "component_amts"]):
		return true
	return PlayerInventory.deduct_cost(recipe["component_ids"], recipe["component_amts"])

# what happens when an entity is hit by something
func _hit_by_spell(spell_info: Dictionary, given_position: Vector2):
	var element_type := ""
	if spell_info.has("element"):
		element_type = spell_info["element"]
	# apply any keywords we know
	if spell_info.has("damage"):
		PlayerStats.take_damage(spell_info["damage"], element_type)
	if spell_info.has("stun_duration"):
		PlayerStats.apply_stun(spell_info["stun_duration"])
	if spell_info.has("add_health"):
		PlayerStats.heal(spell_info["add_health"])
	if spell_info.has("knockback_speed"):
		PlayerStats.apply_knockback(given_position, spell_info["knockback_speed"])
	if spell_info.has_all(["regen", "regen_duration"]):
		PlayerStats.apply_regen_spell(spell_info["regen"], spell_info["regen_duration"], element_type)

func get_facing_direction() -> Vector2:
	return animationTree.get("parameters/Idle/blend_position")

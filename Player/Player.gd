class_name Player
extends Entity
# Member variable declaration

enum {
	MOVE, 
	ROLL, 
	ATTACK,
	SPINNYATTACK,
	CAST
}

var direction_vector = Vector2.DOWN # was roll_vector
var last_input_direction = Vector2.ZERO

var left_click_ability
var right_click_ability
var left_click_ability_id
var right_click_ability_id
var ability_1 = load_ability("FireAttack1")
var ability_2 = load_ability("WindAttack1")
var ability_3 = load_ability("StunAttack")
var ability_4 = load_ability("HomingAttack")
var ability_5 = load_ability("Blink")

# inits when the ready function is ready
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var selectedItemOnGround = $SelectedItemOnGround
onready var cameraHandler = $CameraHandler
var inventory_ui
# Called when the node enters the scene tree for the first time. (init)
func _ready():
	# activate the animation tree.
	animationTree.active = true
	swordHitbox.knockback_vector = direction_vector
	# add the player to the player group
	add_to_group(GroupConstants.PLAYER_GROUP)
	Events.connect("update_action", self, "_update_action")
	inventory_ui = get_tree().get_nodes_in_group("InventoryUI")[0]

func _unhandled_input(event):
	if event.is_action_pressed("sprint"):
		is_sprint = true
	elif event.is_action_released("sprint"):
		is_sprint = false
	elif event.is_action_pressed("attack"):
		state = ATTACK
	elif event.is_action_pressed("spinny attack"):
		state = SPINNYATTACK
	elif event.is_action_pressed("ability_1"):
		use_ability_if_able(ability_1, global_position, direction_vector)
	elif event.is_action_pressed("ability_2"):
		use_ability_if_able(ability_2, global_position, direction_vector)
	elif event.is_action_pressed("ability_3"):
		use_ability_if_able(ability_3, global_position, direction_vector)
	elif event.is_action_pressed("ability_4"):
		use_ability_if_able(ability_4, global_position, direction_vector)
	elif event.is_action_pressed("ability_5"):
		use_ability_if_able(ability_5, global_position, direction_vector)
	elif event.is_action_pressed("left_click"):
		use_ability_if_able(left_click_ability, global_position, global_position.direction_to(get_global_mouse_position()))
func _get_direction():
	var direction_vector : Vector2 = Vector2.ZERO
	direction_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction_vector.y = Input.get_action_strength("ui_down") - Input.get_action_raw_strength("ui_up")
	return direction_vector.normalized()

# Called whenever physics tick happens, delta unlocks movement from framerate
func _physics_process(delta):
	input_vector = _get_direction()
	
	if input_vector != Vector2.ZERO:
		direction_vector = input_vector
		last_input_direction = input_vector
	# forces only 1 state to be running at a time
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state(delta)
		SPINNYATTACK:
			spinny_attack_state(delta)
		CAST:
			cast_state(delta)
		_:
			move_state(delta)
	# set the movement and collision stuff, makes us sticky to collision polygons
	# move_and_collide(velocity * delta)
	# using move and slide so we can slide against walls, doesnt multiply by delta
	# move and slide will handle it for us
	velocity = move_and_slide(velocity)

func move_state(_delta):
	if is_stunned:
		velocity = Vector2.ZERO
	else:
	#	print("in move state")
		# capture knockback_vector from direction vector
		swordHitbox.knockback_vector = direction_vector
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
			if is_sprint:
				velocity = velocity.move_toward(input_vector * SPRINT_MAX_SPEED, SPRINT_ACCELERATION)
			else:
				velocity = velocity.move_toward(input_vector * MOVE_MAX_SPEED, MOVE_ACCELERATION)
			# outdated method
			#velocity += input_vector * ACCELERATION * delta
			#velocity = velocity.clamped(MAX_SPEED * delta)
		else:
			animationState.travel("Idle")
			# slowing down with friction
			velocity = velocity.move_toward(Vector2.ZERO, MOVE_FRICTION)

func attack_state(_delta):
#	print("in attack state")
	# reset your velocity
	velocity = Vector2.ZERO
	#give u a little bit of invincibility frames
	self.set_invincibility()
	# move to attack state and play animation
	animationState.travel("Attack")
	# at the end of the animation it will call attack_animation_finished()


func attack_animation_finished():
#	print("attack finished")
	state = MOVE

func spinny_attack_state(_delta):
	velocity = Vector2.ZERO
	self.set_invincibility()
	animationState.travel("SpinnyAttack")

func roll_animation_finished():
#	print("roll finished")
	if is_sprint:
		velocity.limit_length(SPRINT_MAX_SPEED)
	else:
		velocity.limit_length(MOVE_MAX_SPEED)
	state = MOVE

#This function is currently unused as bullets apply their damage to the enemy
func _on_Hurtbox_area_entered(area):
	#makes sure that you aren't invincible before assigning damage
	if hurtbox.invincible == false:
		take_damage(area.damage)
		# half second invincibility when hit
		hurtbox.start_invincibility(HIT_INVINCIBILITY_TIME)
		hurtbox.create_hit_effect()

func attach_camera(camera_path):
	cameraHandler.set("remote_path", camera_path)

func detach_camera():
	cameraHandler.set("remote_path", "")
	
func cast_state(_delta):
	animationState.travel("Attack")

func create_on_hit_effect():
	hurtbox.create_hit_effect()

# overwrite the _on_no_health() function for the player
# so they dont queue_free because we need the player
# as a reference for the simulation.
func _on_no_health():
	self.visible = false
	self.is_stunned = true
	$Hurtbox.set_invincibility(true)
	# change to player death effect if we ever get one of those.
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	Events.emit_signal("player_died", self)

func _update_action(action: String, ability: String):
	if action == "left_click":
		left_click_ability = load_ability(ability)
		left_click_ability_id = ability
		print(ability)
	elif action == "right_click":
		right_click_ability = load_ability(ability)
		right_click_ability_id = ability

# This function will check if we are on cooldown
# if not, then use the spell and return true
# else return false (no spell cast)
# overwrites the parents version to deduct recipe cost
func use_ability_if_able(spell,initial_position: Vector2, initial_direction: Vector2) -> bool:
	if not is_on_cooldown() and not is_stunned:
		# Deduct the cost of the recipe if there is one
		if inventory_ui.deduct_cost_from_player_inv(RecipeList.get_recipe_by_id(left_click_ability_id)):
			use_ability(spell, initial_position, initial_direction)
			return true
	return false

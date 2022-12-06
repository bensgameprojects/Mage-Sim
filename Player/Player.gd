extends KinematicBody2D
class_name Player
# Member variable declaration

export var ROLL_SPEED = 120
const ONE = 1

enum {
	MOVE, 
	ROLL, 
	ATTACK,
	SPINNYATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var input_vector = Vector2.ZERO
var direction_vector = Vector2.DOWN # was roll_vector
var is_sprint = false
# get the global auto-load singleton for player stats (see project settings auto-load)
var stats = PlayerStats

# inits when the ready function is ready
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var selectedItemOnGround = $SelectedItemOnGround
onready var cameraHandler = $CameraHandler
# Called when the node enters the scene tree for the first time. (init)
func _ready():
	# activate the animation tree.
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	swordHitbox.knockback_vector = direction_vector
	# add the player to the player group
	add_to_group(GroupConstants.PLAYER_GROUP)

func _unhandled_input(event):
	if event.is_action_pressed("sprint"):
		is_sprint = true
	elif event.is_action_released("sprint"):
		is_sprint = false
	elif event.is_action_pressed("roll"):
		state = ROLL
	elif event.is_action_pressed("attack"):
		state =  ATTACK
	elif event.is_action_pressed("spinny attack"):
		state = SPINNYATTACK

# Called whenever physics tick happens, delta unlocks movement from framerate
func _physics_process(delta):
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_raw_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		direction_vector = input_vector
	# forces only 1 state to be running at a time
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)
		SPINNYATTACK:
			spinny_attack_state(delta)
		_:
			move_state(delta)
	# set the movement and collision stuff, makes us sticky to collision polygons
	# move_and_collide(velocity * delta)
	# using move and slide so we can slide against walls, doesnt multiply by delta
	# move and slide will handle it for us
	velocity = move_and_slide(velocity)

func move_state(_delta):
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
			velocity = velocity.move_toward(input_vector * stats.SPRINT_MAX_SPEED, stats.SPRINT_ACCELERATION)
		else:
			velocity = velocity.move_toward(input_vector * stats.MOVE_MAX_SPEED, stats.MOVE_ACCELERATION)
		# outdated method
		#velocity += input_vector * ACCELERATION * delta
		#velocity = velocity.clamped(MAX_SPEED * delta)
	else:
		animationState.travel("Idle")
		# slowing down with friction
		velocity = velocity.move_toward(Vector2.ZERO, stats.MOVE_FRICTION)

func roll_state(_delta):
#	print("in roll state")
	hurtbox.start_invincibility(stats.ROLL_INVINCIBILITY_TIME)
	velocity = direction_vector.normalized() * ROLL_SPEED
	animationState.travel("Roll")
#	if direction_vector != Vector2.ZERO:
#		hurtbox.start_invincibility(stats.ROLL_INVINCIBILITY_TIME)
#		velocity = direction_vector.normalized() * ROLL_SPEED
#		animationState.travel("Roll")
#	else:
#		# dont roll, go back to move state
#		state = MOVE

func attack_state(_delta):
#	print("in attack state")
	# reset your velocity
	velocity = Vector2.ZERO
	#give u a little bit of invincibility frames
	hurtbox.start_invincibility(0.4)
	# move to attack state and play animation
	animationState.travel("Attack")
	# at the end of the animation it will call attack_animation_finished()
	#if Input.is_action_just_released("attack"):
		#state = MOVE

func attack_animation_finished():
#	print("attack finished")
	state = MOVE

func spinny_attack_state(_delta):
	velocity = Vector2.ZERO
	hurtbox.start_invincibility(1.0)
	animationState.travel("SpinnyAttack")

func roll_animation_finished():
#	print("roll finished")
	if is_sprint:
		velocity.limit_length(stats.SPRINT_MAX_SPEED)
	else:
		velocity.limit_length(stats.MOVE_MAX_SPEED)
	state = MOVE

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Hurtbox_area_entered(_area):
	#makes sure that you aren't invincible before assigning damage
	if hurtbox.invincible == false:
		stats.health -= 1
		# half second invincibility when hit
		hurtbox.start_invincibility(stats.HIT_INVINCIBILITY_TIME)
		hurtbox.create_hit_effect()

func attach_camera(camera_path):
	cameraHandler.set("remote_path", camera_path)

func detach_camera():
	cameraHandler.set("remote_path", "")

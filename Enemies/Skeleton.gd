extends Entity

enum {
	IDLE,
	WANDER,
	CHASE,
	CAST
}

var softCollisionPushVector = Vector2.ZERO

var fireball = load_ability("FireAttack1")

var player_stuff

onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var wanderController = $WanderController
onready var animation = $AnimationPlayer
var shoot_timer = Timer.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	state = CHASE
	statePickerRNG.randomize()
	set_state_and_wander_timer()
	add_child(shoot_timer)

func _physics_process(_delta):
	knockback_vector = move_and_slide(knockback_vector)
	knockback_vector = knockback_vector.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION)
	match state:
		IDLE:
			idle_state(_delta)
		WANDER:
			wander_state(_delta)
		CHASE:
			chase_state(_delta)
		CAST:
			cast_state(_delta)
	
	# flip the sprite for the direction its facing
	if velocity.x < 0:
		sprite.flip_h = true
		sprite.offset.x = -9
	elif velocity.x > 0:
		sprite.flip_h = false
		sprite.offset.x = 0
	if not is_stunned:
		velocity = move_and_slide(velocity)

# restarts wander timer and state picking on wander timeout
func set_state_on_wander_timeout():
	# wander timer is up!
	if wanderController.get_time_left() == 0:
		state = pick_random_state([IDLE, WANDER])
		wanderController.start_wander_timer(rand_range(1,3))

#restarts wander timer even if not finished
func set_state_and_wander_timer():
	state = pick_random_state([IDLE,WANDER])
	wanderController.start_wander_timer(rand_range(1,3))

func idle_state(_delta):
	animation.play("default")
	velocity = velocity.move_toward(Vector2.ZERO, MOVE_FRICTION)
	set_state_on_wander_timeout()
	seek_player()
	
func wander_state(_delta):
	animation.play("walk")
	set_state_on_wander_timeout()
	accelerate_to_point(wanderController.target_position)
	# if it wanders close enough to target_position
	if global_position.distance_to(wanderController.target_position) <= wanderController.TARGET_POS_TOLERANCE:
		set_state_and_wander_timer()
	seek_player()
	
func chase_state(_delta):
	animation.play("walk")
	var player = playerDetectionZone.player
	if player != null:
		accelerate_to_point(player.global_position)
		if shoot_timer.is_stopped():
			shoot_timer.connect("timeout", self, "_on_shoot_timer_timeout", [player])
			shoot_timer.start(rand_range(0,3))
	else:
		if not shoot_timer.is_stopped():
			shoot_timer.stop()
			shoot_timer.disconnect("timeout", self, "_on_shoot_timer_timeout")
		set_state_and_wander_timer()
		state = WANDER
		
func cast_state(_delta):
	velocity = Vector2.ZERO

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func pick_random_state(state_list):
	return state_list[statePickerRNG.randi_range(0, state_list.size()-1)]

func accelerate_to_point(position):
	var direction = global_position.direction_to(position)
	# outdated method, equivalent just not as good
#	var direction = (player.global_position - global_position).normalized()
	velocity = velocity.move_toward(direction * MOVE_MAX_SPEED, MOVE_ACCELERATION)

func create_on_hit_effect():
	hurtbox.create_hit_effect()

func _on_shoot_timer_timeout(player):
	player_stuff = player
	if player != null:
		if is_on_cooldown() == false:
			state = CAST
			animation.play("cast")
		shoot_timer.start(rand_range(0,3))

func _on_cast_animation_finished():
	animation.play("default")
	state = CHASE
	
func cast_spell():
	use_ability_if_able(fireball, self.global_position, self.global_position.direction_to(player_stuff.global_position))

extends Entity

enum {
	IDLE,
	WANDER,
	CHASE
}

var softCollisionPushVector = Vector2.ZERO

onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var wanderController = $WanderController
# Called when the node enters the scene tree for the first time.
func _ready():
	state = CHASE
	statePickerRNG.randomize()
	set_state_and_wander_timer()
	MOVE_ACCELERATION = 5
	MOVE_FRICTION = 160
	MOVE_MAX_SPEED = 20
	KNOCKBACK_FRICTION = 20
	KNOCKBACK_SPEED = 200
	max_health = 3
	health = max_health

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
	
	# flip the sprite for the direction its facing
	sprite.flip_h = velocity.x < 0
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
	velocity = velocity.move_toward(Vector2.ZERO, MOVE_FRICTION)
	set_state_on_wander_timeout()
	seek_player()
	
func wander_state(_delta):
	set_state_on_wander_timeout()
	accelerate_to_point(wanderController.target_position)
	# if it wanders close enough to target_position
	if global_position.distance_to(wanderController.target_position) <= wanderController.TARGET_POS_TOLERANCE:
		set_state_and_wander_timer()
	seek_player()
	
func chase_state(_delta):
	var player = playerDetectionZone.player
	if player != null:
		accelerate_to_point(player.global_position)
	else:
		set_state_and_wander_timer()
		state = WANDER

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

func _on_Hitbox_area_entered(area):
	var damage_info := {
	"id":"1dmg_attack",
	"damage":1,
	"knockback_speed":200,
	}
	area.hit_by(damage_info, self.global_position)

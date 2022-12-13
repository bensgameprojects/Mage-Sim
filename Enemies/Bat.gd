extends Entity

enum {
	IDLE,
	WANDER,
	CHASE
}

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

var knockback = Vector2.ZERO
var softCollisionPushVector = Vector2.ZERO


onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var hurtbox = $Hurtbox
onready var wanderController = $WanderController
# Called when the node enters the scene tree for the first time.
func _ready():
	MOVE_ACCELERATION = 20
	MOVE_FRICTION = 160
	MOVE_MAX_SPEED = 80
	SPRINT_MAX_SPEED = 120
	SPRINT_ACCELERATION = 40
	KNOCKBACK_FRICTION = 30
	KNOCKBACK_SPEED = 420
	state = CHASE
	statePickerRNG.randomize()
	set_state_and_wander_timer()

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION)
	
	knockback = move_and_slide(knockback)
	match state:
		IDLE:
			idle_state(_delta)
		WANDER:
			wander_state(_delta)
		CHASE:
			chase_state(_delta)
	
	# flip the sprite for the direction its facing
	sprite.flip_h = velocity.x < 0
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

func _on_Hurtbox_area_entered(area):
	if area.hit_confirm(self):
		health -= area.damage
		knockback = area.knockback_vector.normalized() * KNOCKBACK_SPEED
	#	knockback = Vector2.RIGHT * KNOCKBACK_SPEED
		hurtbox.create_hit_effect()

#called when health <= 0
func _on_Enemy_no_health():
	queue_free()
	#instance the death effect
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	

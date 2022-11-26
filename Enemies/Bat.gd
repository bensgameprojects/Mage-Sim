extends KinematicBody2D

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = CHASE

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

var knockback = Vector2.ZERO
var velocity = Vector2.ZERO

onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var hurtbox = $Hurtbox
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, stats.KNOCKBACK_FRICTION)
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

func idle_state(_delta):
	velocity = velocity.move_toward(Vector2.ZERO, stats.MOVE_FRICTION)
	seek_player()
	
func wander_state(_delta):
	pass
	
func chase_state(_delta):
	var player = playerDetectionZone.player
	if player != null:
		var direction = (player.global_position - global_position).normalized()
		velocity = velocity.move_toward(direction * stats.MOVE_MAX_SPEED, stats.MOVE_ACCELERATION)
	else:
		state = IDLE

func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector.normalized() * stats.KNOCKBACK_SPEED
#	knockback = Vector2.RIGHT * KNOCKBACK_SPEED
	hurtbox.create_hit_effect()

#called when health <= 0
func _on_Stats_no_health():
	queue_free()
	#instance the death effect
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

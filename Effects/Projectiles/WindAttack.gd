extends Bullet

# Declare member variables here. Examples:
# var a = 2
onready var sprite = $AnimatedSprite
onready var properties = $BulletArea

# Called when the node enters the scene tree for the first time.
func _ready():
	speed = 1
	knockback = 1
	damage = 1
	# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(_delta):
	position += velocity
	knockback_vector = velocity.normalized() * knockback
	sprite.rotation_degrees = velocity.angle() * (180/PI)
	properties.knockback_vector = velocity.normalized() * knockback
	properties.damage = damage
	
func setup(bullet_start_position, bullet_direction):
	initial_position = bullet_start_position
	initial_direction = bullet_direction
	position = initial_position
	velocity = speed * bullet_direction

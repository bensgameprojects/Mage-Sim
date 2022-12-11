extends Bullet

# Input stats here:
func _ready():
	speed = 1
	knockback = 1
	damage = 3
	element = "FIRE"
	max_hits_per_entity = 2
	max_hits_before_destruct = 1
	# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(_delta):
	position += velocity
	knockback_vector = velocity.normalized() * knockback
	rotation_degrees = velocity.angle() * (180/PI)
	# check to see if bullet needs to be destroyed or not
	.check_and_destroy_bullet()
#	properties.knockback_vector = velocity.normalized() * knockback
#	properties.damage = damage
	
func setup(caster, bullet_start_position, bullet_direction):
	# call the Bullet function (parent) to set the collision mask
	._set_collision_mask(caster)
	initial_position = bullet_start_position
	initial_direction = bullet_direction
	position = initial_position
	velocity = speed * bullet_direction
	
#adding projectile max duration
func _on_Timer_timeout():
	self.queue_free()

#turning world collision on
func _on_BulletNode_body_entered(body):
	self.queue_free()

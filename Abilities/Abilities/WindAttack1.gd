extends Bullet

# Called when the node enters the scene tree for the first time.
func _ready():
	speed = 1
	knockback_speed = 200
	damage = 1
	element = "WIND"
	max_hits_per_entity = 3
	max_hits_before_destruct = 3
	# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(_delta):
	position += velocity
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


#turning world collision on
func _on_BulletNode_body_entered(_body):
	self.queue_free()

func _on_BulletNode_area_entered(area):
	var entity = area.get_parent()
	if entity is Entity and hit_confirm(entity): # you hit something
		entity.take_damage(damage)
		entity.apply_knockback(self.global_position, knockback_speed)

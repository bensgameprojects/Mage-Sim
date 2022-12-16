extends Bullet

# Called when the node enters the scene tree for the first time.
func _ready():
	speed = 75 # basically max distance the teleport can travel
	element = "WIND"

func _process(_delta):
	pass
	
func setup(caster, bullet_start_position, bullet_direction):
	# call the Bullet function (parent) to set the collision mask
	._set_collision_mask(caster)
	initial_position = bullet_start_position
	initial_direction = bullet_direction
	position = initial_position
	velocity = speed * bullet_direction
	
	# test movement using move_and_collide with the test_only argument == true
	# (its the last argument the other two trues are default settings)
	var collision_info = caster.move_and_collide(velocity, true, true, true)
	if collision_info:
		# Maybe we can allow blinking through some collisions
		# Check out KinematicCollision2D
		# This puts you 2 units away from the collision position
		# so you dont get stuck
		caster.position = collision_info.position - 2*bullet_direction
	else:
		caster.position += velocity
	
	queue_free()


##records position in front of any collidable world objects
#func _on_BulletNode_body_entered(_body):
#	collision_position = self.position
#
#
#
##func _on_BulletNode_area_entered(area):
##	var entity = area.get_parent()
##	if entity is Entity and hit_confirm(entity): # you hit something
##		entity.take_damage(damage)
##		entity.apply_knockback(self.global_position, knockback_speed)
#
#
#func _on_Timer_timeout():
#	if (collision_position == Vector2.ZERO):
#		blink_body.position = self.position
#		queue_free()
#	else:
#		blink_body.position = collision_position
#		queue_free()

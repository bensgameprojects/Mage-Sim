extends Bullet

# Called when the node enters the scene tree for the first time.
func _ready():
	speed = 75 # basically max distance the teleport can travel
	spell_id = "Blink"

func _process(_delta):
	pass
	
func setup(caster, init_position, global_mouse_pos):
	initial_direction = init_position.direction_to(global_mouse_pos)
	blink(caster)
	self.queue_free()

func blink(caster):
		# test movement using move_and_collide with the test_only argument == true
		# (its the last argument the other two trues are default settings)
		#var collision_info = caster.move_and_collide(initial_direction*speed, true, true, true)
		var collision_info = caster.move_and_collide(initial_direction*speed)
		if collision_info:
			# Maybe we can allow blinking through some collisions
			# Check out KinematicCollision2D
			# This puts you 2 units away from the collision position
			# so you dont get stuck
			self.position = collision_info.position - 2*initial_direction

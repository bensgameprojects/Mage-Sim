extends Bullet

func _ready():
	# set the spell_id, the caster will call the setup
	spell_id = "Fireball"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	position += velocity
	# check to see if bullet needs to be destroyed or not
	.check_and_destroy_bullet()
	
func setup(caster, bullet_start_position, global_mouse_pos):
	# call the Bullet function (parent) to set the collision mask
	# set up the initial_position, initial_direction, and initial_mouse_pos
	# variables
	.setup(caster, bullet_start_position, global_mouse_pos)
	velocity = speed * initial_direction
	rotation = initial_direction.angle()

#turning world collision on
func _on_BulletNode_body_entered(_body):
	self.queue_free()

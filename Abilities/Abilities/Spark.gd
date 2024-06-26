extends Bullet
# Called when the node enters the scene tree for the first time.
func _ready():
	spell_id = "Spark"
	speed = 3
	# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(_delta):
	position += velocity
	# check to see if bullet needs to be destroyed or not
	.check_and_destroy_bullet()
#	properties.knockback_vector = velocity.normalized() * knockback
#	properties.damage = damage
	
func setup(hurtbox_layer, bullet_start_position, global_mouse_pos):
	# call the Bullet function (parent) to set the collision mask
	# set up the initial_position, initial_direction, and initial_mouse_pos
	# variables
	.setup(hurtbox_layer, bullet_start_position, global_mouse_pos)
	velocity = speed * initial_direction
	rotation = initial_direction.angle()


#turning world collision on
func _on_BulletNode_body_entered(_body):
	self.queue_free()

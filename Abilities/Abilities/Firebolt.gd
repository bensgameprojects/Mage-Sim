extends Bullet

onready var anim_player = $AnimationPlayer

func _ready():
	spell_id = "Firebolt"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	position += velocity
	#rotation_degrees = initial_direction.angle() * (180/PI)
	# check to see if bullet needs to be destroyed or not
	#.check_and_destroy_bullet()
	
func setup(caster, bullet_start_position, global_mouse_pos):
	# call the Bullet function (parent) to set the collision mask
	# set up the initial_position, initial_direction, and initial_mouse_pos
	# variables
	.setup(caster, bullet_start_position, global_mouse_pos)
	velocity = speed * initial_direction
	self.rotation = initial_direction.angle()

#turning world collision on
func _on_BulletNode_body_entered(_body):
	velocity = Vector2.ZERO
	anim_player.play("hit")

func _on_Bullet_area_entered(area):
	if area is Hurtbox and hit_confirm(area):
		area.hit_by(spell_info, self.global_position)
		velocity = Vector2.ZERO
		anim_player.play("hit")

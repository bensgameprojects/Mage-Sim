extends Bullet

onready var sprite = $AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	spell_id = "Burn"
	sprite.play()

func setup(caster, bullet_start_position, global_mouse_pos):
	# call the Bullet function (parent) to set the collision mask
	# set up the initial_position, initial_direction, and initial_mouse_pos
	# variables
	.setup(caster, bullet_start_position, global_mouse_pos)
	self.rotation = initial_direction.angle() + PI/2

func _on_AnimatedSprite_animation_finished():
	self.queue_free()

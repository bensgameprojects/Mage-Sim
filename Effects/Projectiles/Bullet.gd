class_name Bullet
extends Area2D

var velocity = Vector2.ZERO
var speed
var initial_position
var initial_direction
var knockback
var knockback_vector
var damage
var element: String
var hit_list = {}
var max_hits_per_entity := 1
var max_hits_before_destruct := 1
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GroupConstants.BULLET_GROUP)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# sets the mask depending on the caster
# always respects the world as a collision
func _set_collision_mask(caster):
	# can hit walls
	self.set_collision_mask_bit(LayerConstants.WORLD_LAYER_BIT, true)
	if(caster is Player):
		self.set_collision_mask_bit(LayerConstants.ENEMY_HURTBOX_LAYER_BIT, true)
	else:
		self.set_collision_mask_bit(LayerConstants.PLAYER_HURTBOX_LAYER_BIT, true)

#hit confirm behavior
func hit_confirm(entity) -> bool:
	print(max_hits_before_destruct)
	var key = entity.get_instance_id()
#	var result = false
	if(hit_list.has(key)):
		if (hit_list[key] < max_hits_per_entity and max_hits_before_destruct > 0):
			hit_list[key] += 1
			max_hits_before_destruct -= 1
			return true
		else:
			return false
	elif max_hits_before_destruct > 0:
		hit_list[key] = 1
		max_hits_before_destruct -= 1
		return true
	# catch all
	return false

func check_and_destroy_bullet() -> void:
	if(max_hits_before_destruct == 0):
		self.queue_free()

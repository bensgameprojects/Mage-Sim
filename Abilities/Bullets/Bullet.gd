class_name Bullet
extends Area2D

var velocity = Vector2.ZERO
export var speed = 2
var initial_position
var initial_direction
# speed in m/s to knockback with
# note player speed is 80 so you want to overcome that at least probably
export var knockback_speed := 200.0
export var damage := 1
var element: String
var hit_list = {}
export var max_hits_per_entity := 1
export var max_hits_before_destruct := 1
var destruct_timer = Timer.new()
export var bullet_duration := 3.0

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GroupConstants.BULLET_GROUP)
	destruct_timer.connect("timeout", self, "_on_destruct_timer_timeout")
	add_child(destruct_timer)
	destruct_timer.start(bullet_duration)
	
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
#	print(max_hits_before_destruct)
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

# this function takes an enemy and sees if you can hit them
# by checking to see if they are in the hit_list
func can_hit(entity) -> bool:
	var key = entity.get_instance_id()
	if(hit_list.has(key) and hit_list[key] >= max_hits_per_entity):
		return false
	return true

func check_and_destroy_bullet() -> void:
	if(max_hits_before_destruct == 0):
		self.queue_free()

func _on_destruct_timer_timeout() -> void:
	self.queue_free()

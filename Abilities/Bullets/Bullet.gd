class_name Bullet
extends Area2D

var velocity = Vector2.ZERO
var initial_position
var initial_direction
var initial_mouse_position
var hit_list = {}
var destruct_timer = Timer.new()

var spell_id := ""
var spell_info: Dictionary
var speed := 1.0
var max_hits_per_entity := 1
var max_hits_before_destruct := 1
var bullet_duration := 3.0

var spell_caster
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GroupConstants.BULLET_GROUP)

	if bullet_duration > 0:
		destruct_timer.connect("timeout", self, "_on_destruct_timer_timeout")
		add_child(destruct_timer)
		destruct_timer.start(bullet_duration)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func setup(caster, init_position: Vector2, global_mouse_pos: Vector2):
	spell_info = SpellList.get_spell_data_by_id(spell_id)
	initial_position = init_position
	initial_direction = init_position.direction_to(global_mouse_pos)
	initial_mouse_position = global_mouse_pos
	_set_collision_mask(caster)
	spell_caster = caster
	# position of the area2D itself
	position = initial_position
	self.connect("area_entered", self, "_on_Bullet_area_entered")

# sets the mask depending on the caster
# always respects the world as a collision
func _set_collision_mask(caster):
	# can hit walls
	self.set_collision_mask_bit(LayerConstants.WORLD_LAYER_BIT, true)
	if caster is Entity:
		# hit the player
		self.set_collision_mask_bit(LayerConstants.PLAYER_HURTBOX_LAYER_BIT, true)
	else:
		# hit enemies
		self.set_collision_mask_bit(LayerConstants.ENEMY_HURTBOX_LAYER_BIT, true)

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

func _on_Bullet_area_entered(area):
	if area is Hurtbox and hit_confirm(area):
		area.hit_by(spell_info, self.global_position)

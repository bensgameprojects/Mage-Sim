extends Bullet

onready var animation_player = $AnimationPlayer
onready var seek_area = $SeekArea
var current_target = null
var setup_complete := false
var hit_all_targets_counter = 0
# Called when the node enters the scene tree for the first time.
func _ready():
#	pass
	animation_player.play("start")

func setup(caster, bullet_start_position, bullet_direction):
	# call the Bullet function (parent) to set the collision mask
	._set_collision_mask(caster)
	initial_position = bullet_start_position
	initial_direction = bullet_direction
	position = initial_position
	velocity = speed * bullet_direction
	# We are going to use a new area for homing detection and set it up here
	if caster is Player:
		seek_area.set_collision_mask_bit(LayerConstants.ENEMY_HURTBOX_LAYER_BIT, true)
	else:
		seek_area.set_collision_mask_bit(LayerConstants.PLAYER_HURTBOX_LAYER_BIT, true)

# NOTE: There is an issue with get_overlapping_bodies
# where it does not update right away after the spell is spawned
# in the world which causes find_nearest_target to return null
# and hit_all_targets to return true because it can't find any
# the current workaround is to count the number of times 
# we hit all targets in a row. So now the spell must 
# check that it hit_all_targets() 100 times before
# being able to fizzle

func _process(_delta):
	if(current_target == null):
		current_target = find_nearest_target()
		if(current_target == null and hit_all_targets()):
			hit_all_targets_counter += 1
	else:
		#reset the hit all targets counter cause you found one
		hit_all_targets_counter = 0
		velocity = speed*global_position.direction_to(get_current_target_position())
		global_position += velocity
		rotation_degrees = velocity.angle() * (180/PI)
#			self.queue_free()
#	print(hit_all_targets_counter)
	# if we cant find any more targets to hit 30 times in a row
	# then the spell fizzles
	if(hit_all_targets_counter >= 30):
		self.queue_free()
	.check_and_destroy_bullet()

func _on_BulletNode_body_entered(_body):
	self.queue_free()


func _on_BulletNode_area_entered(area):
	var entity = area.get_parent()
	if entity is Entity and hit_confirm(entity): # you hit something
		entity.take_damage(damage)
		entity.apply_knockback(self.global_position, knockback_speed)
		# reset the current target on hit
		current_target = null


func find_nearest_target():
	var detected_areas = seek_area.get_overlapping_areas()
	var nearest_target = null
	var target_distance = -1
	var candidate_distance = -1
	for area in detected_areas:
		var entity = area.get_parent()
		if entity is Entity and can_hit(entity):
#			print("found entity " + entity.name)
			candidate_distance = self.global_position.distance_to(entity.global_position)
			if nearest_target == null:
				# You are the first or only target available
				nearest_target = entity
				target_distance = candidate_distance
			elif target_distance > candidate_distance:
				# There is a target and the new candidate is closer
				nearest_target = entity
				target_distance = candidate_distance
	return nearest_target

func get_current_target_position():
	if(current_target != null):
		return current_target.global_position
	else:
		return Vector2.ZERO

func hit_all_targets() -> bool:
	var detected_areas = seek_area.get_overlapping_areas()
	for area in detected_areas:
		var entity = area.get_parent()
		if entity is Entity and can_hit(entity):
			return false
	return true

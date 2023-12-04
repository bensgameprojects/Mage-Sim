extends Bullet

onready var animation_player = $AnimationPlayer
onready var seek_area = $SeekArea
var current_target_position = null
var hit_all_targets_counter = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	spell_id = "HomingAttack"
	max_hits_before_destruct = 5
	max_hits_per_entity = 5
	animation_player.play("start")

func setup(caster, bullet_start_position, global_mouse_pos):
	# call the Bullet function (parent) to set the collision mask
	.setup(caster, bullet_start_position, global_mouse_pos)
	velocity = speed * initial_direction
	if caster is Player:
		# We are going to use a new area for homing detection and set it up here
		seek_area.set_collision_mask_bit(LayerConstants.ENEMY_HURTBOX_LAYER_BIT, true)
	else: # set to hit player
		seek_area.set_collision_mask_bit(LayerConstants.PLAYER_HURTBOX_LAYER_BIT, true)

# NOTE: There is an issue with get_overlapping_bodies
# where it does not update right away after the spell is spawned
# in the world which causes find_nearest_target to return null
# and hit_all_targets to return true because it can't find any
# the current workaround is to count the number of times 
# we hit all targets in a row. So now the spell must 
# check that it hit_all_targets() 100 times before
# being able to fizzle

func _physics_process(_delta):
	current_target_position = find_nearest_target_position()
	if(current_target_position == null):
			hit_all_targets_counter += 1
	else:
		#reset the hit all targets counter cause you found one
		hit_all_targets_counter = 0
		velocity = speed*global_position.direction_to(current_target_position)
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
	if hit_confirm(area):
		area.hit_by(spell_info, self.global_position)
		# reset the current target on hit
		current_target_position = null

# returns null if nothing was found, returns a Vector2 global_position
# of the nearest target.
func find_nearest_target_position():
	var detected_areas = seek_area.get_overlapping_areas()
	var nearest_target_position = null
	var target_distance = -1
	var candidate_distance = -1
	for area in detected_areas:
		if (area.get_parent() is Entity or area.get_parent() is Player) and can_hit(area):
#			print("found entity " + entity.name)
			candidate_distance = self.global_position.distance_to(area.global_position)
			if nearest_target_position == null:
				# You are the first or only target available
				nearest_target_position = area.global_position
				target_distance = candidate_distance
			elif target_distance > candidate_distance:
				# There is a target and the new candidate is closer
				nearest_target_position = area.global_position
				target_distance = candidate_distance
	return nearest_target_position

func hit_all_targets() -> bool:
	var detected_areas = seek_area.get_overlapping_areas()
	for area in detected_areas:
		if can_hit(area):
			return false
	return true

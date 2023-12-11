extends Area2D

signal all_waves_defeated

onready var shape = $CollisionShape2D
var mobs: Dictionary
var enemy_ysort : YSort
var killed_mob_count : int = 0
var total_mob_count_in_wave : int = 0
var current_wave : int = -1
var max_waves : int = -1
# For now we will just assume the collision shapes to be square
# and get some upper and lower limits.
var lower_limits : Vector2
var upper_limits : Vector2
# Called when the node enters the scene tree for the first time.
func _ready():
	 lower_limits = shape.position - shape.shape.extents
	 upper_limits = shape.position + shape.shape.extents

func setup(mob_dict: Dictionary, ysort: YSort):
	mobs = mob_dict
	max_waves = mobs.size()
	enemy_ysort = ysort
	initialize_kill_counter()

# this function initializes the spawning of the waves
# each successive wave spawns after all the current enemies have been killed.
func start_spawning() -> void:
	if not mobs.empty():
		spawn_next_wave()

# spawns the enemies for the wave
func spawn_next_wave() -> void:
	current_wave += 1
	# no more waves left.
	if current_wave >= max_waves:
		emit_signal("all_waves_defeated")
		return
	var mob_dict : Dictionary = mobs[current_wave]
	total_mob_count_in_wave = get_enemy_count(mob_dict)
	# each key is the packedscene of a mob
	for key in mob_dict.keys():
		# spawn the number of mobs
		for _i in range(mob_dict[key]):
			# instance a scene
			var new_enemy = key.instance()
			# get the position to spawn it to
			# the enemy will go under SpawnHandler/YSort/Enemies all of which are at
			# global_position (0,0) so setting the global_position is good here
			new_enemy.global_position = self.global_position + (Vector2(
				rand_range(lower_limits.x, upper_limits.x),
				rand_range(lower_limits.y, upper_limits.y)
			))
			# connect to the enemy's no health signal and to track their deaths
			new_enemy.connect("no_health", self, "_on_enemy_no_health", [key])
			# once the enemy is set up, we emit the signal to spawn it under the proper ysort
			# doing it this way will let everybody know that the enemy is spawning and they can
			# react to this happening. It also means that spawn areas dont have to 
			# have a reference to the enemy_ysort, so the spawn areas can be added to other
			# scenes and control them.
			enemy_ysort.add_child(new_enemy)

# enemy dies and we go here
func _on_enemy_no_health(enemy_scene: PackedScene) -> void:
	killed_mob_count += 1
	if killed_mob_count == total_mob_count_in_wave:
		# all the enemies are dead so trigger the next wave, if there is one
		# reset the kill counter as well.
		initialize_kill_counter()
		spawn_next_wave()

func initialize_kill_counter() -> void:
	killed_mob_count = 0

func get_enemy_count(mob_dict : Dictionary) -> int:
	var sum := 0
	for values in mob_dict.values():
		sum += values
	return sum

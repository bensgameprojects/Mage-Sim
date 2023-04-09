extends Area2D

signal all_waves_defeated

onready var shape = $CollisionShape2D
var mobs: Dictionary
var killed_mob_count : Dictionary
var enemy_scenes : Dictionary
var current_wave : int = -1
var max_waves : int = -1
var total_enemy_count : int = -1
var ysort : YSort
# For now we will just assume the collision shapes to be square
# and get some upper and lower limits.
var lower_limits : Vector2
var upper_limits : Vector2
# Called when the node enters the scene tree for the first time.
func _ready():
	 lower_limits = shape.position - shape.shape.extents
	 upper_limits = shape.position + shape.shape.extents

func setup(mob_dict: Dictionary, enemy_scenes_list: Dictionary, enemy_ysort: YSort):
	mobs = mob_dict
	enemy_scenes = enemy_scenes_list
	max_waves = mobs.size()
	ysort = enemy_ysort
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
	# each key is the name of a mob
	for key in mob_dict.keys():
		# spawn the number of mobs
		for i in range(mob_dict[key]):
			# instance a scene
			var new_enemy = enemy_scenes[key].instance()
			# get the position to spawn it to
			new_enemy.set_position(Vector2(
				rand_range(lower_limits.x, upper_limits.x),
				rand_range(lower_limits.y, upper_limits.y)
			))
			# connect to the enemy's no health signal and to track their deaths
			new_enemy.connect("no_health", self, "_on_enemy_no_health", [key])
			ysort.add_child(new_enemy)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
# enemy dies and we go here
func _on_enemy_no_health(enemy_id: String) -> void:
	killed_mob_count[enemy_id] += 1
	if get_enemy_count(killed_mob_count) == get_enemy_count(mobs[current_wave]):
		# all the enemies are dead so trigger the next wave, if there is one
		# reset the kill counter as well.
		initialize_kill_counter()
		spawn_next_wave()

func initialize_kill_counter() -> void:
	for key in enemy_scenes:
		killed_mob_count[key] = 0

func get_enemy_count(mob_dict : Dictionary) -> int:
	var sum := 0
	for values in mob_dict.values():
		sum += values
	return sum

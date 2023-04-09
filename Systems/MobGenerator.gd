extends Node
class_name MobGenerator
# This scene/node will randomly generate groups of mobs
# from the available enemies in the
# enemy_path folder.


# path to the enemies folder.
const enemy_path : String = "res://Enemies/Enemies/"
const enemy_filename_suffix : String = ".tscn"

var rng = RandomNumberGenerator.new()

var enemy_list : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	# Populate the enemy list with the enemies we have to choose from
	_find_enemies_in(enemy_path)
	# Set the rng seed and state
	# randomly generate seed/state values for the rng based on time.
	rng.randomize()

# can be used to manually set the seed and state of the rng
func _seed_rng(seed_value: int, state_value: int) -> void:
	rng.seed = seed_value
	rng.state = state_value

# returns a enemy groups dictionary, keys are the unique group integer id
# and values are mob dictionaries.
# A mob dictionary is keyed by the mobs name string and the value is how many to spawn
# in that group.
func generate_mob_dict(number_of_groups: int, max_enemies_in_group: int) -> Dictionary:
	var group_dict : Dictionary = {}
	# Generate mob dicts for each group.
	for group in range(0,number_of_groups):
		# keep track of the total enemies in the group
		var total_enemy_count: int = 0
		# key : enemy type string, value : number of those enemies in the mob
		var mob_dict := {}
		# shuffle the elements of the enemy list so we dont frontload
		# with the same mobs each time.
		enemy_list.shuffle()
		for enemy_type in enemy_list:
			# if we have capped enemies in the group, no more of the rest.
			if total_enemy_count >= max_enemies_in_group:
				mob_dict[enemy_type] = 0
			else: # otherwise we should generate a value and keep track
				mob_dict[enemy_type] = rng.randi_range(1,max_enemies_in_group - total_enemy_count)
				total_enemy_count += mob_dict[enemy_type]
		group_dict[group] = mob_dict
	return group_dict

# Returns a loaded enemy packedscene for instancing given the enemy name
func load_enemy(enemy_name: String):
	var enemy_scene_path = enemy_path + enemy_name + ".tscn"
	return load(enemy_scene_path)

# loads all the enemies as packed scenes and returns them
# so they can be instanced by a spawner
# enemy_scenes dictionary is keyed by the enemy id string
func load_enemy_list() -> Dictionary:
	var enemy_scenes := {}
	for enemy in enemy_list:
		enemy_scenes[enemy] = load_enemy(enemy)
	return enemy_scenes

# makes a list of all the enemies in the enemy_path folder
# strings of enemy name which can be used to load the enemy
# with the function load_enemy(enemy_name)
func _find_enemies_in(path: String) -> void:
	var directory := Directory.new()
	var error := directory.open(path)
	if error != OK:
		print("Library Error: %s" % error)
		return
	
	error = directory.list_dir_begin(true,true)
	
	if error != OK:
		print("Library Error: %s" % error)
		return 
	
	var filename := directory.get_next()
	
	while not filename.empty():
		if not directory.current_is_dir():
			if filename.ends_with(enemy_filename_suffix):
				# add it to the list
				enemy_list.append(filename.replace(enemy_filename_suffix, ""))
		filename = directory.get_next()
	return

func _test_func() -> void:
	for i in range(1, 4):
		print("Floor ", i, " ", generate_mob_dict(i,10*i),"\n")

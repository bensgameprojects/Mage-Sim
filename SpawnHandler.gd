extends YSort
# This Node handles spawning the player and removing them from the world scene
# In order to facilitate scene switches.

onready var spawnLocation = $SpawnLocation
onready var enemy_ysort = $Enemies

var enemy_spawn_areas : Array
var num_spawn_areas : int = 0
var waves_defeated : int = 0
# preload the mob generator
const mob_generator_scene = preload("res://Systems/MobGenerator.tscn")
var mob_generator : MobGenerator
var player : Player
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GroupConstants.SPAWNHANDLER_GROUP)
	# gets the enemy spawn areas on the map and then fills them up
	enemy_spawn_areas = get_tree().get_nodes_in_group("enemy_spawn_areas")
	num_spawn_areas = enemy_spawn_areas.size()
	if num_spawn_areas >= 1:
		# instance and add the child
		mob_generator = mob_generator_scene.instance()
		add_child(mob_generator)
		# we can remove when we are done spawning dicts.
		var enemy_scenes = mob_generator.load_enemy_list()
		# first set up the mobs
		for spawn_area in enemy_spawn_areas:
			# the call to the mob generator here will make mob dicts/waves for each spawn area.
			# generate_mod_dict(waves, mobs per wave)
			spawn_area.setup(mob_generator.generate_mob_dict(1,1), enemy_scenes, enemy_ysort)
			spawn_area.connect("all_waves_defeated", self, "_on_all_waves_defeated")
		
		# done with the mob generator now so we can get rid of it.
		# to free up some resources.
		remove_child(mob_generator)
		mob_generator.queue_free()
		
		# then tell the spawn areas to begin the waves.
		# for now all of them, later maybe just ones near the player or smth.
		for spawn_area in enemy_spawn_areas:
			spawn_area.start_spawning()

# an enemy spawn area has spawned all of its allocated mobs
# if all the spawn areas have been defeated
# then we allow the player to go back home.
func _on_all_waves_defeated() -> void:
	waves_defeated += 1
	if waves_defeated >= num_spawn_areas:
		unlock_next_level()

# adds the player instance as a child and sets the position to 
# the spawn location's position
func add_player(player_instance):
	add_child(player_instance)
	# save a reference to the player for later
	player = player_instance
	player.set("position", spawnLocation.get_position())

func remove_player() -> Player:
	remove_child(player)
	return player

func unlock_next_level():
	# we can spawn the home portal or the next level if they exist
	# as children of the spawn handler.
	for child in get_children():
		if child.name == "HomeTeleporter":
			child.show()
		elif child.name == "NextFloorTeleporter":
			child.show()

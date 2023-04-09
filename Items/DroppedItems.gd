extends YSort
# This Node handles spawning the player and removing them from the world scene
# In order to facilitate scene switches.

onready var spawnLocation = $SpawnLocation
var enemy_spawn_areas : Array
var player
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GroupConstants.SPAWNHANDLER_GROUP)
	enemy_spawn_areas = get_tree().get_nodes_in_group("enemy_spawn_areas")
	if not enemy_spawn_areas.empty():
		load

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

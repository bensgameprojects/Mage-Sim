extends YSort

onready var spawnLocation = $SpawnLocation
var player
var bullet_start_position
var bullet_direction
var player_spawned = false
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GroupConstants.SPAWNHANDLER_GROUP)
	

# adds the player instance as a child and sets the position to 
# the spawn location's position
func add_player(player_instance):
	add_child(player_instance)
	# save a reference to the player for later
	player = player_instance
	player_instance.set("position", spawnLocation.get_position())
	player_spawned = true

func remove_player() -> Player:
	remove_child(player)
	return player
	player_spawned = false

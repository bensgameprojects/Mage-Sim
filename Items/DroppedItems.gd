extends YSort

onready var spawnLocation = $SpawnLocation
var player
signal Bullet_entity_spawned
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
	connect("Bullet_entity_spawned", get_tree().get_nodes_in_group("Player")[0], "_on_SpawnHandler_Bullet_spawned")

func remove_player() -> Player:
	remove_child(player)
	return player
	
func _on_Bullet_spawned():
	emit_signal("Bullet_entity_spawned")

extends Node2D
# This Node handles spawning the player and removing them from the world scene
# In order to facilitate scene switches.

onready var spawnLocation = $SpawnLocation
onready var enemy_ysort = $YSort/Enemies
onready var dropped_stuff = $YSort/DroppedStuff

var label_ysort

var enemy_spawn_areas : Array
var num_spawn_areas : int = 0
var waves_defeated : int = 0
var player : Player

#Generic item scene to instance
const item_scene = preload("res://Items/Item.tscn")
const damage_effect = preload("res://UI/DamageValue.tscn")
const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group(GroupConstants.SPAWNHANDLER_GROUP)
	label_ysort = YSort.new()
	add_child(label_ysort)
	# CONNECT to the spawn item event to carry out those requests
	Events.connect("spawn_item", self, "_spawn_item")
	Events.connect("spawn_spell", self, "_spawn_spell")
	Events.connect("display_value", self, "place_damage_label")
	Events.connect("death_effect", self, "place_death_effect")
	# gets the enemy spawn areas on the map and then fills them up
	enemy_spawn_areas = get_tree().get_nodes_in_group("enemy_spawn_areas")
	num_spawn_areas = enemy_spawn_areas.size()
	if num_spawn_areas >= 1:
		# first set up the mobs
		for spawn_area in enemy_spawn_areas:
			# the call to the mob generator here will make mob dicts/waves for each spawn area.
			# generate_mod_dict(waves, mobs per wave)
			spawn_area.setup(MobGenerator.generate_mob_dict(1,1), enemy_ysort)
			spawn_area.connect("all_waves_defeated", self, "_on_all_waves_defeated")
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
	enemy_ysort.add_child(player_instance)
	# save a reference to the player for later
	player = player_instance
	player.position = spawnLocation.get_position()

func remove_player() -> Player:
	enemy_ysort.remove_child(player)
	return player

func unlock_next_level():
	# we can spawn the home portal or the next level if they exist
	# as children of the spawn handler.
	for child in get_children():
		if child.name == "HomeTeleporter":
			child.show()
		elif child.name == "NextFloorTeleporter":
			child.show()

#this function makes an item given the parent node to spawn it under.
func _spawn_item(item_id : String, item_count: int, spawn_position, requestor_node):
	var item_texture = ItemsList.get_item_data_by_id(item_id)["image"]
	var new_item = item_scene.instance()
	dropped_stuff.add_child(new_item)
	new_item.setup(item_id, item_count, spawn_position, item_texture)
	# give back to the node who requested the spawn.
	if requestor_node != null and requestor_node.has_method("receive_item"):
		requestor_node.receive_item(new_item)

func _spawn_spell(spell: PackedScene, initial_position: Vector2, global_mouse_pos: Vector2, caster):
	if spell != null:
		var spell_instance = spell.instance()
		add_child(spell_instance)
		spell_instance.setup(caster, initial_position, global_mouse_pos)

func place_damage_label(value, type, position):
		var dmg_label = damage_effect.instance()
		label_ysort.add_child(dmg_label)
		dmg_label.display_value(value, type, position)

func place_death_effect(position):
	var enemyDeathEffect = EnemyDeathEffect.instance()
	enemy_ysort.add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = position

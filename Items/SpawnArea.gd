extends Area2D

export(String) var item_ID = ""
#export(String) var item_texture_path = ""
var item_texture_path := ""
# time in seconds
export var respawn_time = 3
export var max_stack = 3
export var min_stack = 1
#onready var spawnRegion = $SpawnRegion
onready var ySort = $YSort
onready var spawnRegion = $CollisionShape2D
var spawnTimer
onready var itemScene = preload("res://Items/Item.tscn")

var item_reference : Dictionary
# You can use these functions to move a spawn area or change it's radius
# while the game is running. They work but have no use atm.
# To change the radius of a spawn area you can make a SpawnArea and
# enable Editable Children by right-clicking it
# Then you can click on the collision shape in the 2D scene inspector
# and adjust it's radius and position that way.
func setSpawnRegionRadius(radius):
	if radius > 0:
		spawnRegion.shape.set_radius(radius)

func getSpawnRegionRadius():
	return spawnRegion.shape.radius

func getSpawnRegionPosition():
	return spawnRegion.position

func getYSortNode():
	return ySort

# Called when the node enters the scene tree for the first time.
func _ready():
	item_reference = ItemsList.get_item_data_by_id(item_ID)
	item_texture_path = item_reference["image"]
	spawnTimer = Timer.new()
	spawnTimer.connect("timeout", self, "_on_SpawnTimer_timeout")
	add_child(spawnTimer)
	spawnTimer.start(respawn_time)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# reset timer and spawn new item
func _on_SpawnTimer_timeout():
	# timer will be paused and reset because a new item will be made
	spawnTimer.set_paused(true)
#	spawnTimer.start(respawn_time)
	var stack_size = int(round(rand_range(min_stack,max_stack)))
#	print("spawn timer timed out! about to make a new item")
#	emit_signal("needsNewItem", self, item_ID, stack_size)
	# replace the signal emit with make new item itself
	var new_item = itemScene.instance()
	add_child(new_item)
	new_item.set_item_id(item_ID)
	new_item.set_sprite_texture(load(item_texture_path))
	new_item.set_collision_layer_bit(LayerConstants.GATHERABLE_ITEM_LAYER_BIT, true)
	# get a position inside the spawn area
	var radius = getSpawnRegionRadius()
#	var position = spawnArea.getSpawnRegionPosition()
	# putting the item somewhere in the area by randomly generating
	# a direction vector and then multiplying by the radius of the spawnArea
	# spawnAreas must always be circles also since we add the new item
	# as a child of the spawnArea, the position is relative to the center of the
	# spawn area, i.e the spawnArea.position = 0,0
	var nudge = Vector2(rand_range(-1,1),rand_range(-1,1)).normalized() * radius
	nudge.x = nudge.x * rand_range(0,1)
	nudge.y = nudge.y * rand_range(0,1)
#	newItem.spawn_sprite(position+nudge)
	new_item.spawn_sprite(nudge)
	# this signal will get caught in the inventoryUI and a corresponding
	# item will be made in the world inventory with a reference
	# only one thing babyy
	var inventoryUI = get_tree().get_nodes_in_group("InventoryUI")[0]
	inventoryUI.create_new_dropped_item(new_item, stack_size)
	# ok now these hm... i think i need to hook it up in the UI probably
	new_item.connect("ItemEnteredPickupRange", inventoryUI, "add_to_pickup_stack")
	new_item.connect("ItemExitedPickupRange", inventoryUI, "remove_from_pickup_stack")
#	print("made the item!")
	


func _on_SpawnArea_body_exited(body):
	if body is GatherableItem and body.has_method("get_item_id") and body.get_item_id() == item_ID:
		#called when the gatherable item that spawned is leaves the area
		# spawn timer should be started and unpaused
		spawnTimer.set_paused(false)
		spawnTimer.start(respawn_time)

# if there is an item then the spawn timer should be paused
func _on_SpawnArea_body_entered(body):
	if body is GatherableItem and body.has_method("get_item_id") and body.get_item_id() == item_ID:
		spawnTimer.set_paused(true)

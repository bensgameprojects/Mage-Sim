extends Area2D

export(String) var item_ID = ""
export(String) var item_texture_path = ""
# time in seconds
export var respawn_time = 3
export var max_stack = 3
export var min_stack = 1
export(float) var spawnRadius = 50.0
#onready var spawnRegion = $SpawnRegion
onready var ySort = $YSort
var spawnRegion
var spawnRegionShape
var spawnTimer
onready var itemScene = preload("res://Items/Item.tscn")
const GATHERABLE_ITEM_LAYER_BIT = 9


func setSpawnRegionRadius(radius):
	if radius > 0:
		spawnRadius = radius
		spawnRegionShape.set_radius(radius)

func getSpawnRegionRadius():
	return spawnRegion.shape.radius

func getSpawnRegionPosition():
	return spawnRegion.position

func getYSortNode():
	return ySort

# Called when the node enters the scene tree for the first time.
func _ready():
	spawnRegion = CollisionShape2D.new()
	spawnRegionShape = CircleShape2D.new()
	spawnRegionShape.set_radius(spawnRadius)
	spawnRegion.set_shape(spawnRegionShape)
	add_child(spawnRegion)
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
	new_item.set_collision_layer_bit(GATHERABLE_ITEM_LAYER_BIT, true)
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
	


func _on_SpawnArea_body_exited(_body):
	#called when the gatherable item that spawned is leaves the area
	# spawn timer should be started and unpaused
	spawnTimer.set_paused(false)
	spawnTimer.start(respawn_time)

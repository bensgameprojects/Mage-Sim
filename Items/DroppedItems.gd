extends YSort
onready var player = $Player
onready var droppedItems = $DroppedItems
const GATHERABLE_ITEM_LAYER_BIT = 9

signal transfer_item_to_player_inv(itemToTransfer)

signal create_and_add_item_to_world_inv(spawn_area, itemID, stackSize)

var itemScene = preload("res://Items/Item.tscn")
var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()

func add_player(playerScene):
	add_child(playerScene)

func _on_SpawnArea_needsNewItem(spawn_area, item_ID, stack_size):
	create_new_dropped_item(spawn_area, item_ID, stack_size)

func create_new_dropped_item(spawn_area, itemID, stackSize):
	# tell inventory to go make the item
	emit_signal("create_and_add_item_to_world_inv", spawn_area, itemID, stackSize)

#the above signal will make the item and, if successful will return
# the item here and run this code before the emit_signal returns
func _on_InventoryUI_item_created_in_world_inv(spawnArea, item):
	var newItem = itemScene.instance()
	var texture = item.get_texture()
#	spawnArea.getYSortNode().add_child(newItem)
	spawnArea.add_child(newItem)
#	add_child_below_node(spawnArea, newItem)
	newItem.set_item_reference(item)
	newItem.set_sprite_texture(texture)
	# set this to true so that the spawn region can detect if an item is already spawned
	newItem.set_collision_layer_bit(GATHERABLE_ITEM_LAYER_BIT, true)
	# get a position inside the spawn area
	var radius = spawnArea.getSpawnRegionRadius()
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
	newItem.spawn_sprite(nudge)
	newItem.connect("ItemEnteredPickupRange", player, "addToPickupStack", [newItem])
	newItem.connect("ItemExitedPickupRange", player, "removeFromPickupStack", [newItem])


func respawnItemInWorld(itemInstance):
	itemInstance.spawn_sprite(player.global_position)
	itemInstance.visible = true


func _on_InventoryUI_item_dropped_to_floor(item):
	# create a new item on the floor
	var newItem = itemScene.instance()
	var texture = item.get_texture()
	var location_nudge = Vector2(rng.randi_range(1, 8), rng.randi_range(1,8))
	droppedItems.add_child(newItem)
	newItem.set_item_reference(item)
	newItem.set_sprite_texture(texture)
	newItem.spawn_sprite(player.global_position + location_nudge)
	newItem.connect("ItemEnteredPickupRange", player, "addToPickupStack", [newItem])
	newItem.connect("ItemExitedPickupRange", player, "removeFromPickupStack", [newItem])


func _on_Player_pickup_item_inv_transfer(itemInstance):
#	print("on_player_pickup_item_inv_transfer entered for item " + itemInstance.get_item_reference().get_property("id"))
#	itemInstance.set_pickup_detection_monitoring(false)
#	print("pickup detection monitoring set false" + str(itemInstance.get_pickup_detection_monitoring()))
	var itemToTransfer = itemInstance.get_item_reference()
	emit_signal("transfer_item_to_player_inv", itemToTransfer)
#	print("emitted signal: transfer_item_to_player_inv")
	itemInstance.queue_free()
#	print("queue_freed the item instance")


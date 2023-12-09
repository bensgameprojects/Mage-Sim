extends Area2D

export(String) var item_ID = ""
# time in seconds
export var respawn_time = 3
export var max_stack = 3
export var min_stack = 1
onready var spawn_region = $CollisionShape2D
var spawnTimer = Timer.new()
var item_reference : GatherableItem

# You can use these functions to move a spawn area or change it's radius
# while the game is running. They work but have no use atm.
# To change the radius of a spawn area you can make a SpawnArea and
# enable Editable Children by right-clicking it
# Then you can click on the collision shape in the 2D scene inspector
# and adjust it's radius and position that way.
func setSpawnRegionRadius(radius):
	if radius > 0:
		spawn_region.shape.set_radius(radius)

func getSpawnRegionRadius():
	return spawn_region.shape.radius

func getSpawnRegionPosition():
	return spawn_region.position

# Called when the node enters the scene tree for the first time.
func _ready():
	item_reference = null
	spawnTimer.connect("timeout", self, "_on_SpawnTimer_timeout")
	add_child(spawnTimer)
	spawnTimer.start(respawn_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# reset timer and spawn new item
func _on_SpawnTimer_timeout():
	# timer will be paused and reset because a new item will be made
	spawnTimer.paused = true
	# determine how many items to spawn
	var item_count = int(round(rand_range(min_stack,max_stack)))
#	print("spawn timer timed out! about to make a new item")
	# get a position inside the spawn area
	var radius = getSpawnRegionRadius()
#	var position = spawnArea.getSpawnRegionPosition()
	# putting the item somewhere in the area by randomly generating
	# a direction vector and then multiplying by the radius of the spawnArea
	# spawnAreas must always be circles also since we add the new item
	# as a child of the spawnArea, the position is relative to the center of the
	# spawn area
	var spawn_position = self.position + Vector2(rand_range(-1,1),rand_range(-1,1)).normalized() * radius
	Events.emit_signal("spawn_item", item_ID, item_count, spawn_position, self)

func receive_item(item: GatherableItem):
	item_reference = item

func _on_SpawnArea_body_exited(body):
	if body == item_reference:
		#called when the gatherable item that spawned is leaves the area
		# spawn timer should be started and unpaused
		spawnTimer.paused = false
		spawnTimer.start(respawn_time)

# if there is an item then the spawn timer should be paused
func _on_SpawnArea_body_entered(body):
	if body == item_reference:
		spawnTimer.paused = true

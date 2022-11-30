extends Area2D

export var item_ID = ""
# time in seconds
export var respawn_time = 3
export var max_stack = 3
signal needsNewItem(spawn_area, item_ID, stack_size)
onready var spawnRegion = $SpawnRegion
onready var spawnTimer = $SpawnTimer
onready var ySort = $YSort

func setSpawnRegionRadius(radius):
	if radius > 0:
		spawnRegion.shape.radius = radius

func getSpawnRegionRadius():
	return spawnRegion.shape.radius

func getSpawnRegionPosition():
	return spawnRegion.position

func getYSortNode():
	return ySort

# Called when the node enters the scene tree for the first time.
func _ready():
	spawnTimer.start(respawn_time)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# reset timer and spawn new item
func _on_SpawnTimer_timeout():
	# timer will be paused and reset because a new item will be made
	spawnTimer.set_paused(true)
#	spawnTimer.start(respawn_time)
	var stack_size = int(round(rand_range(1,max_stack)))
#	print("spawn timer timed out! about to make a new item")
	emit_signal("needsNewItem", self, item_ID, stack_size)
#	print("made the item!")


func _on_SpawnArea_body_exited(_body):
	#called when the gatherable item that spawned is leaves the area
	# spawn timer should be started and unpaused
	spawnTimer.set_paused(false)
	spawnTimer.start(respawn_time)

extends Control

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var label = $Label
onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty

func set_hearts(value):
	# trust stat block is sane
	hearts = value
	# not using label but im leaving it for now as an example
	if label != null:
		label.text = "HP = " + str(hearts)
	# we are tiling the heart sprite
	# its 15 pixels wide so we are scaling
	# the width by hearts and size of hearts
	if heartUIFull !=  null:
		heartUIFull.rect_size.x = hearts * 15


func set_max_hearts(value):
	# trust stat block is sane
	max_hearts = value
	# makes sure if max health changed then cant have more hearts
	# than you can have max_hearts
	self.hearts = min(hearts, max_hearts)
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = max_hearts * 15

# Called when the node enters the scene tree for the first time.
func _ready():
	self.max_hearts = PlayerStats.max_health
	self.hearts = PlayerStats.health
	# connect at ready: signal, object to get connect it to, function to run
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

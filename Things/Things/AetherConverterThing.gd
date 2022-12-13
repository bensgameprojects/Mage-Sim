extends Thing


onready var power := $PowerSource
onready var animation_player := $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	# for now just play the one
	# but it will be configured depending on the type
	animation_player.play("generate_air_power")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

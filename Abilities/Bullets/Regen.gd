extends Node

# whoever gets the regen node will connect to
# this signal and run its take_damage function with
# the amount sent
signal regen_tick(amount, damage_type)

# this signal is so that if there is animations for freeze/burn/etc
# we can turn it off if there is no more effect happening
signal regen_ended(damage_type)

const tick_rate = 1

var regen_amount : float = 0.0
var regen_duration : float = 0.0
var damage_type : String = ""

var tick_time : float = 0.0
var time_elapsed : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# call this function after instancing the scene to set the values
# then add it to the scene tree to start the regen/dot
func setup(amount : float, duration : float, type: String):
	regen_amount = amount
	regen_duration = duration
	damage_type = type
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_elapsed += delta
	tick_time += delta
	if tick_time >= tick_rate:
		tick_time = 0
		emit_signal("regen_tick", regen_amount, damage_type)
	if time_elapsed >= regen_duration:
		emit_signal("regen_ended", damage_type)
		queue_free()

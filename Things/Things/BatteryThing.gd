extends Thing


export var max_storage := 1000.0

# The amount of power the batter is currently holding
# See the setter function below to see how
# we use it to update the source and receiver component's efficiency
var stored_power := 0.0 setget _set_stored_power

onready var receiver := $PowerReceiver
onready var source := $PowerSource
onready var charge_label = $ChargeIndicator
onready var sprite = $Sprite
# Called when the node enters the scene tree for the first time.
func _ready():
	# If the source is not omnidirectional:
	if source.output_direction != 15:
		# Set the receiver direction to the opposite of the source
		# The ^ is XOR operator
		receiver.input_direction = 15 ^ source.output_direction

# The setup function fetches the direction from the blueprint
# applies it to the source and inverts it for the receiver with XOR (^)
func _setup(blueprint: BlueprintThing) -> void:
	source.output_direction = blueprint.power_direction.output_directions
	receiver.input_direction = 15 ^ source.output_direction
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _set_stored_power(value: float) -> void:
	# We set the stored power and prevent it from becoming negative.
	stored_power = max(value,0)
	# Wait until the thing is ready to ensure
	# we have access to the nodes
	if not is_inside_tree():
		yield(self, "ready")
		
	# set the receiver's efficiency
	receiver.efficiency = (
		0.0
		# If the battery is full, set it to 0. Dont draw more power
		if stored_power >= max_storage
		# If the batter is les than full, set it between 1 
		# and the percentage of how empty the battery is
		# This makes the battery fill up slower as it approaches
		# being full
		else min((max_storage - stored_power) / receiver.power_required, 1.0)
	)
	
	# Set the source efficiency to 0 if there is no power.
	# Otherwise, set it to a percentage of how full the battery is.
	# A battery that has more power than it must provide returns 1,
	# whereas a battery that has less returns some percentage of that.
	source.efficiency = (0.0 if stored_power <= 0 else min(stored_power/source.power_amount, 1.0))
	charge_label.text = str(stored_power) + " / " + str(max_storage)

func get_info() -> String:
	return "Storing %-4.1f / %s energy" % [stored_power, max_storage]

func _on_PowerSource_power_updated(power_draw, delta):
	self.stored_power = stored_power - min(power_draw, source.get_effective_power()) * delta
	Events.emit_signal("info_updated", self)


func _on_PowerReceiver_received_power(amount, delta):
	self.stored_power = stored_power + amount * delta
	Events.emit_signal("info_updated", self)

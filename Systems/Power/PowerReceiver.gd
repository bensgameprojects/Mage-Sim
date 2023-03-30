# Receive power from connected power source
class_name PowerReceiver
extends Node

## Signal for the entity to react to it for when the receiver gets an amount of
## power each system tick.
## A battery can increase the amount of power stored, or an electric furnace can
## begin smelting ore once it receives the power it needs.
signal received_power(amount, delta)


# The maximum amount of power the machine can receive in units per tick.
export var power_required := 10.0

# The possible power elements you could create, default to all
# will probably just wanna do 1 when we get the elemental stuff all squared
# away
export (Types.Element, FLAGS) var element_type := 15
# The possible directions for power to come 'out' of the machine
# The default value, 15, makes it omnidirectional
# The FLAGS export hint below turns the value display in the Inspector into
# a checkbox list
export (Types.Direction, FLAGS) var input_direction := 15

# How efficient the machine currently is. For instance, a machine that has no work
# to do has an efficiency of 0' where one that has a job has an efficiency of '1'
var efficiency := 0.0

# Returns a float indicating the possible power multiplied by the current efficiency
func get_effective_power() -> float:
	return power_required * efficiency

func save() -> Dictionary:
	var save_dict = {
		"component_id" : "PowerReceiver",
		"power_required" : var2str(power_required),
		"element_type" : var2str(element_type),
		"input_direction" : var2str(input_direction),
		"efficiency" : var2str(efficiency),
	}
	return save_dict

func load_state(save_dict: Dictionary) -> bool:
	if (
		save_dict.has_all(["component_id", "power_required", "element_type", "input_direction", "efficiency"])
		and save_dict["component_id"] == "PowerReceiver"
		):
		var load_value: float = str2var(save_dict["power_required"])
		power_required = load_value
		load_value = str2var(save_dict["efficiency"])
		efficiency = load_value
		var load_value_int: int = str2var(save_dict["element_type"])
		element_type = load_value_int
		load_value_int = str2var(save_dict["input_direction"])
		input_direction = load_value_int
		
		return true
	return false

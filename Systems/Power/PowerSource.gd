# Provide connected machines with power of whatever type
class_name PowerSource
extends Node

# Signal for the power system to notify the component that it took
# a certain amount of power from the power source. Allows things
# to react accordingly. For example, a batter can lower its stored amount
# or a generator can burn a tick of fuel.
signal power_updated(power_draw, delta)


# The maximum amount of power the machine can provide in units per tick.
export var power_amount := 10.0

# The possible power elements you could create, default to all of them
export (Types.Element, FLAGS) var element_type := 15
# The possible directions for power to come 'out' of the machine
# The default value, 15, makes it omnidirectional
# The FLAGS export hint below turns the value display in the Inspector into
# a checkbox list
export (Types.Direction, FLAGS) var output_direction := 15

# How efficient the machine currently is. For instance, a machine that has no work
# to do has an efficiency of '0' where one that has a job has an efficiency of '1'
var efficiency := 1.0

# Returns a float indicating the possible power multiplied by the current efficiency
func get_effective_power() -> float:
	return power_amount * efficiency

func save() -> Dictionary:
	var save_dict = {
		"component_id" : "PowerSource",
		"power_amount" : var2str(power_amount),
		"element_type" : var2str(element_type),
		"output_direction" : var2str(output_direction),
		"efficiency" : var2str(efficiency),
	}
	return save_dict

func load_state(save_dict: Dictionary) -> bool:
	if (
		save_dict.has_all(["component_id","power_amount", "element_type", "output_direction", "efficiency"])
		and save_dict["component_id"] == "PowerSource"
		):
		# enforcing typing on the load.
		var load_power_amount: float = str2var(save_dict["power_amount"])
		var load_element_type: int = str2var(save_dict["element_type"])
		var load_output_direction: int = str2var(save_dict["output_direction"])
		var load_efficiency: float = str2var(save_dict["efficiency"])
		power_amount = load_power_amount
		element_type = load_element_type
		output_direction = load_output_direction
		efficiency = load_efficiency
		return true
	return false

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

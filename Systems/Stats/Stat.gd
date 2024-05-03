extends Object
class_name Stat

signal stat_changed(computed_value)

# A stat has its base value, an additive bonus, and a multiplicative bonus.
var base := 1.0 setget _set_base
var add := 0.0
var mult := 1.0

# take the base stat, add any additive modifiers then multiply any scaling bonus
func compute() -> float:
	return (base + add)*mult

func _set_base(value: float):
	base = value
	emit_signal("stat_changed", self.compute())

# things that apply and remove stat changes to this stat
# use these functions.

# applies a stat to this one
func apply(other_stat: Stat):
	add += other_stat.add
	mult += other_stat.mult
	emit_signal("stat_changed", self.compute())

# removes a stat from this one
func remove(other_stat: Stat):
	add -= other_stat.add
	mult -= other_stat.mult
	emit_signal("stat_changed", self.compute())

# Not gonna use this, I'm going to use an equipment resource superclass
# each equipment will extend it and implement the functions.
# An equipment, skill or buff will have a stat_dictionary
# with one or more of these keywords
func merge(stat_dict: Dictionary):
	if stat_dict.has("add"):
		add += stat_dict["add"]
	if stat_dict.has("mult"):
		mult += stat_dict["mult"]
	emit_signal("stat_changed", self.compute())

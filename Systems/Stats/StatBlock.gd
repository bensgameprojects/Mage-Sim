extends Object
class_name StatBlock

# additive increases add flat damage to the spell
# multipliers occur after.
var attack = Stat.new()
var fire_attack = Stat.new()
var water_attack = Stat.new()
var earth_attack = Stat.new()
var wind_attack = Stat.new()
var heal_potency = Stat.new()

var defense = Stat.new()
# anything above 100% is clamped to 100%, can go below 0
var fire_resist = Stat.new()
var water_resist = Stat.new()
var earth_resist = Stat.new()
var wind_resist = Stat.new()

# anything above 100% is clamped to 100%, can go below 0
var knockback_resist = Stat.new()
var stun_resist = Stat.new()
var cooldown_reduction = Stat.new()

var move_speed = Stat.new()
var sprint_speed = Stat.new()

var max_health = HealthStat.new()

# Unique modifiers dictionary object, keyed by spell id.
# functions: get(spell_id: String) and add(modifier_dict)
var modifiers = Modifiers.new()

# Called when the node is created
# Set some base values for these, default is 1
func _init():
	move_speed.base = 60
	sprint_speed.base = 120
	max_health.base = 3
	fire_resist.base = 0
	water_resist.base = 0
	earth_resist.base = 0
	wind_resist.base = 0
	cooldown_reduction.base = 0
	knockback_resist.base = 0
	stun_resist.base = 0

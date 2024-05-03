extends Equipment


var fire_attack := Stat.new()
var fire_resist := Stat.new()

func _init():
	fire_attack.add = 1
	# gives 100% fire resist (for testing :)
	fire_resist.add = 100
	description = "+1 Fire Attack \n+100% Fire Resist"

func equip():
	PlayerStats.stat_block.fire_attack.add(fire_attack)
	PlayerStats.stat_block.fire_resist.add(fire_resist)

func unequip():
	PlayerStats.stat_block.fire_attack.remove(fire_attack)
	PlayerStats.stat_block.fire_resist.remove(fire_resist)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

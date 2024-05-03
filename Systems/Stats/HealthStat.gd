extends Stat
class_name HealthStat

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#don't allow the max health to go below 1
func compute():
	return max(1,(self.base + self.add)*self.mult)


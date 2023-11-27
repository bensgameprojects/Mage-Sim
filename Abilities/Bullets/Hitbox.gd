extends Area2D

var damage := 1
var knockback_speed := 300.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Bullet_area_entered(area):
	var entity = area.get_parent()
	if entity is Entity: # you hit something
		entity.take_damage(damage)
		entity.apply_knockback(self.global_position, knockback_speed)

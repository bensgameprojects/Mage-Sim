extends Area2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Bullet_area_entered(area):
	area.hit_by("1dmg_attack")

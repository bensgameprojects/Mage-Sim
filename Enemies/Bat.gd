extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var knockback = Vector2.ZERO

onready var stats = $Stats

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, stats.KNOCKBACK_FRICTION)
	knockback = move_and_slide(knockback)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector.normalized() * stats.KNOCKBACK_SPEED
#	knockback = Vector2.RIGHT * KNOCKBACK_SPEED



func _on_Stats_no_health():
	queue_free()

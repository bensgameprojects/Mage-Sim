class_name GatherableItem
extends KinematicBody2D

export(int) var COLLISION_SPEED = 2
export(int) var COLLISION_FRICTION = 10
export(int) var MAX_COLLISION_SPEED = 2
onready var itemSprite = $ItemSprite
onready var softCollision = $SoftCollision
onready var pickupDetection = $PickupDetection
var velocity = Vector2.ZERO
var collisionCounter = 0
var item
var item_ID

signal ItemEnteredPickupRange
signal ItemExitedPickupRange

func set_item_id(item_id):
	item_ID = item_id

func get_item_id():
	return item_ID

func set_item_reference(inventoryItem):
	item = inventoryItem

func get_item_reference():
	return item

func set_sprite_texture(texture):
	itemSprite.set_texture(texture)

#maybe you want an offset for this as well depending on the item idk
# spawn location is a position
func spawn_sprite(spawn_location):
	self.position = spawn_location
	self.visible = true

func set_pickup_detection_monitoring(enabled):
	pickupDetection.monitoring = enabled
	pickupDetection.monitorable = enabled


# you might want to check these sometimes
func get_pickup_detection_monitoring():
	return pickupDetection.monitoring

func get_pickup_detection_monitorable():
	return pickupDetection.monitorable

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false

func _physics_process(_delta):
	if collisionCounter == 0:
		velocity = velocity.move_toward(Vector2.ZERO, COLLISION_FRICTION)
	velocity = move_and_slide(velocity)

#two items are too close
func _on_SoftCollision_area_entered(area):
	var direction = global_position.direction_to(area.global_position)
	# var distance = global_position.distance_to(area.global_position)
	# what happens when distance is 0?
	collisionCounter += 1
	velocity += direction * COLLISION_SPEED
	velocity.limit_length(MAX_COLLISION_SPEED)


func _on_SoftCollision_area_exited(_area):
	collisionCounter -= 1
	if(collisionCounter == 0):
		velocity = Vector2.ZERO

# player has entered the pickup range
func _on_PickupDetection_area_entered(_area):
	# someone to deal with this
	emit_signal("ItemEnteredPickupRange", self)


func _on_PickupDetection_area_exited(_area):
	# someone to deal with this
	emit_signal("ItemExitedPickupRange", self)

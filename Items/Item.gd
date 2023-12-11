class_name GatherableItem
extends KinematicBody2D

export(int) var COLLISION_SPEED = 2
export(int) var COLLISION_FRICTION = 10
export(int) var MAX_COLLISION_SPEED = 2
onready var item_sprite = $ItemSprite
onready var softCollision = $SoftCollision
onready var interact = $InteractComponent
var velocity = Vector2.ZERO
var collisionCounter = 0

# necessary item info
var item_ID
var item_count

func setup(item_id: String, item_cnt: int, spawn_position, texture):
	set_item_id(item_id)
	set_item_count(item_cnt)
	set_sprite_texture(texture)
	set_collision_layer_bit(LayerConstants.GATHERABLE_ITEM_LAYER_BIT, true)
	spawn_sprite(spawn_position)
	interact.connect("interact_pressed", self, "_on_interact")
	var item_name = ItemsList.get_item_name_by_id(item_ID)
	set_prompt()

func set_prompt():
	var item_name = ItemsList.get_item_name_by_id(item_ID)
	if item_count > 1:
		interact.set_prompt("Pickup " + str(item_count) + " " + item_name + "s.")
	else:
		interact.set_prompt("Pickup " + str(item_count) + " " + item_name + ".")

func set_item_count(item_cnt: int):
	item_count = item_cnt

func set_item_id(item_id):
	item_ID = item_id

func get_item_id():
	return item_ID

func get_item_count():
	return item_count

func set_sprite_texture(texture):
	item_sprite.set_texture(load(texture))

# spawn location is a position
func spawn_sprite(spawn_location):
	self.position = spawn_location
	self.visible = true

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
	collisionCounter += 1
	velocity += direction * COLLISION_SPEED
	velocity.limit_length(MAX_COLLISION_SPEED)


func _on_SoftCollision_area_exited(_area):
	collisionCounter -= 1
	if(collisionCounter == 0):
		velocity = Vector2.ZERO

func _on_interact():
			var items_leftover = PlayerInventory.add_or_merge(item_ID, item_count)
			if items_leftover > 0:
				# change the number of items in the stack on the ground
				set_item_count(items_leftover)
				# put back in pickup stack
				Events.emit_signal("interact_entered_range", interact)
			else:
				#item is added to the inventory so delete the item from the ground
				queue_free()

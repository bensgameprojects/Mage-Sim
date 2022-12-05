extends Area2D


export(String) var building_id
var building
onready var buildingList = get_node("/root/BuildingList")
var sprite
var worldCollision
var worldCollisionShape
# Called when the node enters the scene tree for the first time.
func _ready():
	# get the meta data for this building
	building = buildingList.get_building_by_id(building_id)
	sprite = Sprite.new()
	sprite.set_texture(building["texture_path"])
	add_child(sprite)
	worldCollision = CollisionShape2D.new()
	# for now im just going to set the shape to be a circle
	# but we might want something more sophisticated for each building later
	worldCollisionShape = CircleShape2D.new()
	worldCollisionShape.set_radius(30)
	worldCollision.add_child(worldCollisionShape)
	add_child(worldCollision)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

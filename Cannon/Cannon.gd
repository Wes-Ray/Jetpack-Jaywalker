extends Node2D

onready var laser = $Body/Laser
onready var raycast = $Body/Laser/RayCast2D
onready var collider = $Body/Laser/CollisionShape2D
onready var sprite = $Body/Laser/Sprite


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func project_beam():
	raycast.enabled = true
	raycast.force_raycast_update()
	var laser_start_pos = laser.global_position
	var collision_pos = raycast.get_collision_point()
	var laser_length = laser_start_pos.distance_to(collision_pos)
	var laser_midpoint = (laser_length/2)
	print("laser pos: " , laser_start_pos, "   collision_pos: ", collision_pos)
	print("LASER_LENGTH: " , laser_length, "    LASER_MIDPOINT: " , laser_midpoint)
	collider.position.y = laser_midpoint
	print(collider.position.y) 
	sprite.position.y = laser_midpoint
	collider.shape.height  = laser_length
	print(collider.shape.height)
	sprite.region_rect.size.y = laser_length



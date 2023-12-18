extends Node2D

onready var laser = $Body/Laser
onready var raycast = $Body/Laser/RayCast2D
onready var collider = $Body/Laser/CollisionShape2D
onready var sprite = $Body/Laser/Sprite
onready var light = $Body/Laser/Light2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	project_beam()

func project_beam():
	## force a raycast update at function call
	raycast.enabled = true
	raycast.force_raycast_update()
	# calculate laser length and midpoint based on the raycast collision pos
	var laser_length = laser.global_position.distance_to(raycast.get_collision_point())
	var laser_midpoint = (laser_length / 2)
	# update laser children positions/sizes to fit raycast
	# NOTE: parent "Body" node rotates, so the children nodes only need y-axis rescaling
	collider.position.y = laser_midpoint
	sprite.position.y = laser_midpoint
	light.position.y = laser_midpoint
	collider.shape.height  = laser_length
	sprite.region_rect.size.y = laser_length
	light.scale.y = laser_length / 60



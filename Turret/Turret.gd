extends Node2D

onready var laser = $Body/Laser
onready var raycast = $Body/Laser/RayCast2D
onready var collider = $Body/Laser/CollisionShape2D
onready var sprite = $Body/Laser/Sprite
onready var light = $Body/Laser/Light2D

enum {PLACEMENT, ACTIVE}

var GROUND_Y_COORD = 425
var CEILING_Y_COORD = 225

var state = PLACEMENT
var target_replay 
var fire_offset := 0.0
var beam_secs := 1.7
var aim_lead = Vector2(4, 0)

func _ready():
	target_replay = get_parent().get_last_replay_ref()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if state == PLACEMENT:
		move_turret()
	project_beam()


func project_beam():
	# force a raycast update at function call
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


func move_turret():
	var mouse_pos = get_global_mouse_position()
	position.x = mouse_pos.x
	# set turret y position based on snapping thresholds
	# TODO: this check doesn't work on window resize
	if mouse_pos.y > get_viewport().size.y / 2:
		position.y = GROUND_Y_COORD
		scale.y = 1
	else:
		position.y = CEILING_Y_COORD
		scale.y = -1
	if Input.is_action_just_released("def_place_trap"):
		print("placing turret at: ", position)
		print("Time is: ", get_parent().round_time / 1000.00)
		place(get_parent().round_time)

	# set angle depending if player is above or below the turret
	$Body.rotation = ((target_replay.position + aim_lead) - global_position).angle() 
	if (target_replay.position.y > position.y):
		$Body.rotation *= -1
	$Body.rotation += PI/2


func place(round_time:float):
	state = ACTIVE

	$AnimationPlayer.play("fire")
	fire_offset = $AnimationPlayer.current_animation_length - (fmod(round_time, $AnimationPlayer.current_animation_length))
	$AnimationPlayer.seek(beam_secs)


func reset():
	$AnimationPlayer.play("fire")
	$AnimationPlayer.seek(fire_offset + beam_secs)


func _on_Laser_area_entered(area:Area2D):
	print(Time.get_ticks_msec())
	print("LASER HIT SOMETHING")
	print("LASER HIT: ", area)
	if area.is_in_group("replay"):
		print("replay hit")
		# note: this requires that the parent of the target area is the player itself
		area.get_parent().damage()

	if area.is_in_group("player"):
		print("player hit")
		area.get_parent().damage()

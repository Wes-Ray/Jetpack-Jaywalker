extends Node2D

onready var laser = $Body/Laser
onready var raycast = $Body/Laser/RayCast2D
onready var collider = $Body/Laser/CollisionShape2D
onready var sprite = $Body/Laser/Sprite
onready var light = $Body/Laser/Light2D

enum {PLACEMENT, ACTIVE}

var state = PLACEMENT
var target_replay 
var fire_offset := 0.0
var beam_secs := 1.5
var aim_lead = Vector2(3, 0)

func _ready():
	target_replay = get_parent().get_last_replay_ref()


# Called every frame. 'delta' is the elapsed time since the previous frame.
# TODO: Why does this break when changed to physics proc?
func _process(_delta):
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


func aim_beam():
	# set angle depending if player is above or below the turret
	if (target_replay.position.y > position.y):
		$Body.rotation = -((target_replay.position + aim_lead)  - global_position).angle() + PI/2
	else:
		$Body.rotation = ((target_replay.position + aim_lead) - global_position).angle() + PI/2


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

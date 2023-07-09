extends Node2D


onready var camera = $Camera2D
var active_trap := Node2D

onready var wiper: Sprite = $Wiper
onready var wipe_goal: Position2D = $WipeGoal
onready var unwipe_goal: Position2D = $UnwipeGoal
onready var current_wiper_goal: Vector2 = $WipeGoal.position

var velocity := Vector2.ZERO

# trap preloads, in a list for random selection
const preloads := [
	preload("res://Zap/Zap.tscn"), 
#	preload("res://Buzz/Buzz.tscn"),
#	preload("res://Laser/Laser.tscn"),
#	preload("res://Ray/Ray.tscn"),
	]


var active = false


func _ready() -> void:
	Orchestrator.register_defense(self)


func unwipe():
	current_wiper_goal = unwipe_goal.position
	camera.current = true


func reset_defense_camera() -> void:
	self.position.x = 550


func activate_defense() -> void:
	unwipe()
	
	# generate new trap
	var rand_i = randi() % len(preloads)
	var new_trap = preloads[rand_i].instance()
	get_tree().get_current_scene().add_child(new_trap)
	
#	new_trap.z_index = 3
	active_trap = new_trap
	
	reset_defense_camera()
	
	active = true


func deactivate_defense() -> void:
	current_wiper_goal = wipe_goal.position
	active = false


func strafe_defense_camera() -> void:
	var strafe_input = Input.get_axis("move_left", "move_right")
	velocity.x = move_toward(velocity.x, 5 * strafe_input, 0.25)
	
	self.position.x += velocity.x
	self.position.x = clamp(position.x, 550, 1150)


func _physics_process(_delta: float) -> void:
	wiper.position = lerp(wiper.position, current_wiper_goal, 0.2)
	
	if not active:
		return
	
	# animate trap on cursor location
#	active_trap.position = get_local_mouse_position()
	active_trap.position = get_global_mouse_position()
	
	# place track at cursor location
	if Input.is_action_just_pressed("def_place_trap"):
		active = false
	
	# strafe
	strafe_defense_camera()
	
	
	# these two items might go into signals instead of physics_process
	# if player dies, switch back to offense
	# if player makes it to goal, game over


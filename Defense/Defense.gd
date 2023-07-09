extends Node2D


onready var camera = $Camera2D
var active_trap := Node2D

# trap preloads, in a list for random selection
const preloads := [
	preload("res://Zap/Zap.tscn"), 
	preload("res://Buzz/Buzz.tscn"),
	preload("res://Laser/Laser.tscn"),
	preload("res://Ray/Ray.tscn"),
	]

#const zap_preload := preload("res://Zap/Zap.tscn")
#const zap_preload := preload("res://test.tscn")
# const player_preload := preload("res://Player/Player.tscn")

var active = false


func _ready() -> void:
	Orchestrator.register_defense(self)


func _physics_process(_delta: float) -> void:
	if not active:
		return
	
	Orchestrator.global_ui.text = str(active_trap.position, "\n", $Sprite.position)
	
	# animate trap on cursor location
	active_trap.position = get_local_mouse_position()
	$Sprite.position = get_local_mouse_position()
	
	# place track at cursor location
	if Input.is_action_just_pressed("def_place_trap"):
		active = false
	
	
	# these two items might go into signals instead of physics_process
	# if player dies, switch back to offense
	# if player makes it to goal, game over


func activate_defense() -> void:
	print("activate defense")
	camera.current = true
	
	# generate new trap
	var rand_i = randi() % len(preloads)
	var new_trap = preloads[rand_i].instance()
	add_child(new_trap)
	
#	new_trap.z_index = 3
	active_trap = new_trap
	
	active = true

func deactivate_defense() -> void:
	active = false

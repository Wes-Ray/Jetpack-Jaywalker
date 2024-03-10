extends Camera2D

onready var wiper = $Wiper

func _ready() -> void:
	# TODO: set sprite size based on camera/screen resolution
	pass

func wipe_to_target(target : Vector2) -> void:
	print("wiping to target")

	# pass target as a % of screen width/height
	# 0.0, 0.0 is upper left; 1.0, 1.0 is lower right
	# TODO: send resolution from godot instead of hard code
	print("x: ", target.x, " y: ", target.y)
	print("\tcam: ", position)

	var norm = target - position
	print("\tnormalized: ", norm)
	
	var screen_dims = get_viewport().get_visible_rect().size * zoom

	
	target.x = (norm.x / screen_dims.x) + 0.5
	target.y = (norm.y / screen_dims.y) + 0.5 

	print("\tconverted: ", target)

	wiper.material.set_shader_param("target", target)
	print("Time is: ", Time.get_ticks_msec() / 1000.00)
	wiper.material.set_shader_param("start_time", Time.get_ticks_msec() / 1000.00)
extends Camera2D

onready var sprite = $Sprite

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

	target.x = (target.x / (1024/2)) - 0.5
	target.y = (target.y / (600/2)) - 0.5

	print("\tconverted: ", target)

	sprite.material.set_shader_param("target", target)

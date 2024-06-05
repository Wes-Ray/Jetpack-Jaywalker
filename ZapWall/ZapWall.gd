extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
# func _ready():
#	pass

func _on_Area2D_area_entered(area: Area2D) -> void:
	# Orchestrator.apply_damage(area)
	print('warp wall applying damage')
	if area.is_in_group("replay"):
		print("replay hit")
		# note: this requires that the parent of the target area is the player itself
		area.get_parent().damage()

	if area.is_in_group("player"):
		print("player hit")
		area.get_parent().damage()

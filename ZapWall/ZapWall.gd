extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
# func _ready():
#	pass

func _on_Area2D_area_entered(_area: Area2D) -> void:
	# Orchestrator.apply_damage(area)
	print('DAMAGED')

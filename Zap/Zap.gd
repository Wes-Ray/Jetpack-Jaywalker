extends Node2D


onready var new_orchestrator = preload("res://Main.gd")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
# func _ready():
#	pass

func _on_Area2D_area_entered(area: Area2D) -> void:
	new_orchestrator.apply_damage(area)
	print('DAMAGED')

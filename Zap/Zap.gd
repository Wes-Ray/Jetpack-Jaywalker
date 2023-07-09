extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Area2D.connect("area_entered", self, "_on_Area2D_area_entered")

func _on_Area2D_area_entered(area: Area2D) -> void:
	Orchestrator.apply_damage(area)
	print('DAMAGED')

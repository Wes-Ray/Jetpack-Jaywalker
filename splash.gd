extends Node2D


const main_preload := preload("res://cannon_level.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_released("ui_accept"):
		get_tree().change_scene_to(main_preload)

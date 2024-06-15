extends Node2D


const main_preload := preload("res://Scenes/Level.tscn")


func _process(_delta: float) -> void:
	if Input.is_action_just_released("ui_accept"):
		var err = get_tree().change_scene_to(main_preload)
		if err != OK:
			print("error loading scene: ", err)

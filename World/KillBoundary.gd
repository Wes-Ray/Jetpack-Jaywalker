extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# TODO: refactor? 
func _on_KillBoundary_area_entered(_area):
	# Orchestrator.apply_damage(area)
	pass

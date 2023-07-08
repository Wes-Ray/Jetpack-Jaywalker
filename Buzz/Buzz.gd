extends Node2D

export var rotation_speed = 180
export var radius = 50
var blade
var i = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	blade = $Blade
	$AnimationPlayer.play("spin")


func _process(_delta):
	blade.position.x = sin((float(i)/rotation_speed)*TAU) * radius
	blade.position.y = cos((float(i)/rotation_speed)*TAU) * radius
	i = (i+1) % rotation_speed


func _on_Blade_area_entered(area: Area2D) -> void:
	Orchestrator.apply_damage(area)

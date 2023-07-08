extends Node2D

var ray


# Called when the node enters the scene tree for the first time.
func _ready():
	ray = $RayCast2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func ray_warning():
	ray.enabled = true
	ray.force_raycast_update()
	var ray_distance = abs($RayBegin.global_position.x - ray.get_collision_point().x)
	$Area2D.global_position.x = $RayBegin.global_position.x - ray_distance / 2
	$Area2D/WarnSprite.visible = true
	$Area2D/FireSprite.visible = false
	$Area2D/WarnSprite.region_rect.size.x = ray_distance
	
	
func ray_fire():
	ray.enabled = true
	ray.force_raycast_update()
	var ray_distance = abs($RayBegin.global_position.x - ray.get_collision_point().x)
	$Area2D.global_position.x = $RayBegin.global_position.x - ray_distance / 2
	$Area2D/FireSprite.visible = true
	$Area2D/WarnSprite.visible = false
	$Area2D/FireSprite.region_rect.size.x = ray_distance
	$Area2D/CollisionShape2D.shape.extents.x = ray_distance / 2
	
func ray_off():
	ray.enabled = false
	$Area2D.global_position.x = $RayBegin.global_position.x
	$Area2D/CollisionShape2D.shape.extents.x = 0
	$Area2D/FireSprite.visible = false
	$Area2D/WarnSprite.visible = false


func _on_Area2D_area_entered(area):
	GlobalReplayOrchestrator.apply_damage(area)

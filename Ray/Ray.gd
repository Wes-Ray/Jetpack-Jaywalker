extends Node2D

onready var firing := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if firing:
		update_ray()

func ray_warning():
	firing = true
	update_ray()
	$CollisionShape2D.disabled = true
	$FireSprite.visible = false
	$WarnSprite.visible = true
	
	
func ray_fire():
	firing = true
	update_ray()
	$CollisionShape2D.disabled = false
	$FireSprite.visible = true
	$WarnSprite.visible = false
	
func update_ray():
	$RayCast2D.enabled = true
	$RayCast2D.force_raycast_update()
	var ray_distance = self.global_position.x - $RayCast2D.get_collision_point().x
	$CollisionShape2D.position.x = 0 - ray_distance / 2
	$CollisionShape2D.shape.extents.x = ray_distance / 2
	$WarnSprite.position.x = 0 - ray_distance / 2
	$WarnSprite.region_rect.size.x = abs(ray_distance)
	$FireSprite.position.x = 0 - ray_distance / 2
	$FireSprite.region_rect.size.x = abs(ray_distance)
	
func ray_off():
	firing = false
	$RayCast2D.enabled = false
	$CollisionShape2D.position.x = 0
	$CollisionShape2D.shape.extents.x = 0
	$CollisionShape2D.disabled = true
	$FireSprite.visible = false
	$WarnSprite.visible = false


func _on_Area2D_area_entered(area):
	Orchestrator.apply_damage(area)

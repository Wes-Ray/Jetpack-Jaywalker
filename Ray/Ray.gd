extends Node2D

onready var firing := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if firing:
		update_ray()

func ray_warning():
	firing = true
	update_ray()
	$CollisionShape2D.disabled = true
	$FireSprite.visible = false
	$WarnSprite.visible = true
	$Light2D.visible = true
	$Light2D.energy = 0.5
	$AudioStreamPlayer2D.play()
	
	
func ray_fire():
	firing = true
	update_ray()
	$CollisionShape2D.disabled = false
	$FireSprite.visible = true
	$WarnSprite.visible = false
	$Light2D.visible = true
	$Light2D.energy = 0.8
	
	
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
	$Light2D.position.x = 0 - ray_distance / 2
	$Light2D.scale.y = abs(ray_distance) / 60
	
func ray_off():
	firing = false
	$RayCast2D.enabled = false
	$CollisionShape2D.position.x = 0
	$CollisionShape2D.shape.extents.x = 0
	$CollisionShape2D.disabled = true
	$FireSprite.visible = false
	$WarnSprite.visible = false
	$Light2D.visible = false
	$AudioStreamPlayer2D.stop()

func _on_Area2D_area_entered(area):
	Orchestrator.apply_damage(area)

extends Area2D

onready var new_orchestrator = preload("res://Main.gd")
onready var firing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if firing:
		update_laser()

func laser_fire():
	firing = true
	update_laser()
	$CollisionShape2D.disabled = false
	$Sprite.visible = true
	$Light2D.visible = true
	
func update_laser():
	$RayCast2D.enabled = true
	$RayCast2D.force_raycast_update()
	var ray_distance = self.global_position.y - $RayCast2D.get_collision_point().y
	$CollisionShape2D.position.y = 0 - ray_distance / 2
	$CollisionShape2D.shape.extents.y = ray_distance / 2
	$Sprite.position.y = 0 - ray_distance / 2
	$Sprite.region_rect.size.y = abs(ray_distance)
	$Light2D.position.y = 0 - ray_distance / 2
	$Light2D.scale.y = abs(ray_distance) / 60
	

func laser_off():
	firing = false
	$RayCast2D.enabled = false
	$CollisionShape2D.position.y = 0
	$CollisionShape2D.shape.extents.y = 0
	$CollisionShape2D.disabled = true
	$Sprite.visible = false
	$Light2D.visible = false


func _on_BottomLaser_area_entered(area):
	new_orchestrator.apply_damage(area)


func _on_TopLaser_area_entered(area):
	new_orchestrator.apply_damage(area)

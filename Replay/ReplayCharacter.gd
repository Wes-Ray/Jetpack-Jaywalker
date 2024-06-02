extends Node2D

signal replay_killed

var pos_data := []
var anim_data := []
var reset_pos : Vector2
var corpse : Sprite  # set to visible/invisible and update location on death

var lerp_prev_pos: Vector2
var lerp_next_pos: Vector2
var tick_wait_time : float

var delta_since_tick : float

var is_alive := true
onready var collision_shape := $Area2D/CollisionShape2D


func init(_pos_data : Array, _anim_data : Array, start_pos : Vector2, _tick_wait_time : float, _corpse : Sprite):
	pos_data = _pos_data  # already duplicated in calling function
	anim_data = _anim_data
	position = start_pos
	reset_pos = start_pos
	tick_wait_time = _tick_wait_time
	corpse = _corpse
	corpse.visible = false


func reset():
	if reset_pos:
		position = reset_pos
	is_alive = true
	collision_shape.set_deferred("disabled", false)
	
	print("reset to: ", position)


func update_pos(next_pos : Vector2) -> void:
	lerp_prev_pos = position
	lerp_next_pos = next_pos
	delta_since_tick = 0.0

func update_anim(next_anim : String) -> void:
	if($AnimationPlayer.current_animation != next_anim):
		$AnimationPlayer.current_animation = next_anim


func _physics_process(delta: float) -> void:
	delta_since_tick += delta
	position = lerp(lerp_prev_pos, lerp_next_pos, clamp(delta_since_tick / tick_wait_time, 0, 1) )


# returns false when pos_data runs out or replay is not alive
func replay(tick : int) -> bool:
	if not is_alive:
		return false

	if tick < len(pos_data):
		# print("replay", self, " tick:", tick)
		# print("\treplay position: ", pos_data[tick])
		if tick == 0:
			visible = true
			position = pos_data[tick]
		# position = pos_data[tick]
		update_pos(pos_data[tick])
		update_anim(anim_data[tick])
		
		return true
	else:
		# TODO: naive implementation of disappearance up reaching goal, this should probably be triggered by a goal emitted overlap event
		if($AnimationPlayer.current_animation != "death"):
			self.visible = false
		return false


# TODO: remove
func test():
	print("TEST REPLAY")


# called by enemy objects that might damage the replay
func damage():
	print("REPLAY took dmg")
	is_alive = false
	collision_shape.set_deferred("disabled", true)
	update_anim("death")
	emit_signal("replay_killed")

	# spawn blood splat (under player? can also just be on timer)
	corpse.position = position
	corpse.visible = true
	print("corpse pos: ", corpse.position)

extends Node2D


var pos_data := []
var reset_pos : Vector2

var lerp_prev_pos: Vector2
var lerp_next_pos: Vector2
var tick_wait_time : float

var total_delta : float


func init(pos_list : Array, start_pos : Vector2, _tick_wait_time : float):
	pos_data = pos_list  # already duplicated in calling function
	position = start_pos
	reset_pos = start_pos
	tick_wait_time = _tick_wait_time


func reset():
	if reset_pos:
		position = reset_pos
	
	print("reset to: ", position)


func update_pos(prev_pos : Vector2, next_pos : Vector2) -> void:
	lerp_prev_pos = prev_pos
	lerp_next_pos = next_pos
	total_delta = 0.0


func _physics_process(delta: float) -> void:
	total_delta += delta
	position = lerp(lerp_prev_pos, lerp_next_pos, clamp(total_delta / tick_wait_time, 0, 1) )

	print(position)


# returns false when pos_data runs out
func replay(tick : int) -> bool:
	if tick < len(pos_data):
		# print("replay", self, " tick:", tick)
		# print("\treplay position: ", pos_data[tick])
		
		# position = pos_data[tick]
		update_pos(position, pos_data[tick])
		
		return true
	else:
		
		return false


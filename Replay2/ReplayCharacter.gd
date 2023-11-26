extends KinematicBody2D


var pos_data := []
var reset_pos : Vector2


func init(pos_list : Array, start_pos : Vector2):
	pos_data = pos_list  # already duplicated in calling function
	position = start_pos
	reset_pos = start_pos


func reset():
	if reset_pos:
		position = reset_pos
	
	print("reset to: ", position)


# returns false when pos_data runs out
func replay(tick : int) -> bool:
	if tick < len(pos_data):
		print("replay", self, " tick:", tick)
		print("\treplay position: ", pos_data[tick])
		
		position = pos_data[tick]
		
		return true
	else:
		return false

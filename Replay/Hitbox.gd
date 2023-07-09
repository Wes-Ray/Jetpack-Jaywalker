extends Area2D



func kill_replay(state = Orchestrator.PlayerStates.DEAD):
	get_parent().kill_replay(state)

extends Node

const enemy_lib = preload("res://libraries/enemy_lib.gd")

func physics_process():
	# move towards target
	if(owner.target != null):
		owner.move()
	else: owner.velocity = Vector2.ZERO


#func attack():
	## if has attack state
	#if(owner.state_node.ATTACK != null):
		#owner.set_state(owner.states.ATTACK)
		#owner.state.attack()

extends Node

const enemy_lib = preload("res://libraries/enemy_lib.gd")

func physics_process():
	# move towards target
	if(owner.target != null):
		var direction = owner.global_position.direction_to(owner.target.global_position)
		owner.velocity = direction * owner.stats.speed
	else: owner.velocity = Vector2.ZERO


func attack():
	# if has attack state
	print("BBBB")
	if(owner.state_node.ATTACK != null):
		print("AAAAAAAAAAAAA")
		owner.set_state(owner.states.ATTACK)
		owner.state.attack()

extends Node

func _ready():
	pass
	
func physics_process():
	# move towards target
	if(owner.target != null):
		var direction = owner.global_position.direction_to(owner.target.global_position)
		owner.velocity = direction * owner.stats.speed
	else: owner.velocity = Vector2.ZERO

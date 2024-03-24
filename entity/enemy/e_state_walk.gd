extends Node

const enemy_lib = preload("res://libraries/enemy_lib.gd")

func physics_process():
	# move towards target
	if(owner.target != null):
		var direction = owner.global_position.direction_to(owner.target.global_position)
		owner.velocity = direction * owner.stats.speed
	else: owner.velocity = Vector2.ZERO


func _on_enemy_damage_taken():
	match owner.ability:
		enemy_lib.ability_type.SWORD: attack()

func attack():
	# if has attack animation
	if("attack" in owner.sprite.sprite_frames.get_animation_names()):
		owner.set_state(owner.states.ATTACK)
		owner.state.attack()

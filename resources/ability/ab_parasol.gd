extends Ability

const attack_scn : PackedScene = preload("res://entity/attacks/area_attack.tscn")

@export var radius = 100

var attack : Node2D = null # current attack

func on_level_changed():
	
	super.on_level_changed()
	
	if attack == null:
		attack = init_attack(attack_scn)
		update_attack()
		attack.color = Color.ROYAL_BLUE
		parent.add_child(attack)
		attack.position = Vector2.ZERO
	else:
		update_attack()
	print_debug(attack.position)

func update_attack():
	atk_update_damage(attack)
	attack.radius = radius * ability_stats.size

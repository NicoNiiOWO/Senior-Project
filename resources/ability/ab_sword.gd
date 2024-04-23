extends Ability

const attack_scn : PackedScene = preload("res://entity/attacks/proj_sword.tscn")
#var attack : Projectile = null



func make_attack() -> Projectile:
	var new_attack = init_attack(attack_scn)
	new_attack.set_direction(parent.direction)
	new_attack.global_position = parent.position + parent.direction*30
	
	return new_attack

func on_attack():
	var proj = make_attack()
	parent.get_parent().add_child(proj)


func get_next_lvl_text(_lvl=self.level):
	return super.get_next_lvl_text()

func on_level_changed():
	super.on_level_changed()

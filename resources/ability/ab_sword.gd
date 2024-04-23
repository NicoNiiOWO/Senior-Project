extends Ability

const projectile_scn : PackedScene = preload("res://entity/attacks/projectile.tscn")
var projectile_base : Projectile = null

func make_attack():
	var proj = projectile_scn.instantiate()
	proj.init_projectile(parent.type, parent.stats.atk*ability_stats.atk_mod)
	proj.set_duration(0.5)
	proj.speed = 800
	proj.size *= ability_stats.size
	
	projectile_base = proj

func on_attack():
	if projectile_base == null:
		make_attack()
	
	var proj = projectile_base.duplicate()
	proj.damage = parent.stats.atk * ability_stats.atk_mod
	proj.size = ability_stats.size
	proj.set_direction(parent.direction)
	proj.global_position = parent.position + parent.direction*30
	
	parent.get_parent().add_child(proj)
	proj.set_sprite(load("res://entity/attacks/sword_atk.tres"), "enemy")
	
	print_debug("AAAA ", proj.size)


func get_next_lvl_text(lvl=self.level):
	print_debug("s",lvl)
	#if lvl == 0: return super.get_next_lvl_text()
	#else: return str("AAAAA ", level+1)
	return super.get_next_lvl_text()

func on_level_changed():
	super.on_level_changed()
	print_debug("changed")

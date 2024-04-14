extends Resource
class_name Stats

const char_lib = preload("res://libraries/char_lib.gd")
const enemy_lib = preload("res://libraries/enemy_lib.gd")

# Stats
# Enemy stats defined in enemy_lib
@export var base : Dictionary = {
	level = 1,
	max_exp = 100,
	exp = 0,
	max_hp = 100,
	atk = 10,
	speed = 250,
	atk_size = 1.0, # attack size multiplier
	dmg_taken = 1.0, # damage taken multiplier
	iframes = 0.25, # invincibility frames in seconds
}
# Stat increase per level
@export var growth : Dictionary = {
	max_hp = 5,
	atk = 1.5,
	max_exp = 1.2, # multiply
	speed = 1,
	atk_size = 0.02
}

# Current stats
@export var current : Dictionary = {} 

func set_type(char_type:int, ability:int=0):
	if(char_type == Global.char_type.PLAYER):
		current.iframes = 0
	else:
		base = enemy_lib.get_base_stats(ability)
		growth = enemy_lib.get_growth_stats(ability)
	
	current = base.duplicate()
	current.hp = current.max_hp

# update stats based on level
func update():
	for stat in ["max_hp", "atk", "speed"]:
		current[stat] = calc_add(stat)
	current["atk_size"] = calc_add("atk_size", 0.01)
	current["max_exp"] = calc_mult("max_exp")

# calculate stat based on level
func calc_add(stat:String, round_to:float=1.0, base:Dictionary=base, growth:Dictionary=growth, level:int=current.level):
	return snapped(base[stat] + growth[stat] * (level-1), round_to)

func calc_mult(stat:String, round_to:float=1.0, base:Dictionary=base, growth:Dictionary=growth, level:int=current.level):
	return snapped(floor(base[stat] * pow(growth[stat], level-1)), round_to)

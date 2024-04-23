extends Resource
class_name Stats

signal stats_updated()

#const char_lib = preload("res://libraries/char_lib.gd")
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
	max_hp = 1.05,
	atk = 1.5,
	max_exp = 1.2, # multiply
	speed = 1,
	atk_size = 0.02
}

# Current stats
@export var current : Dictionary = {}

@export var stat_mods : Dictionary = {}

var isPlayer = false
var ability = -1

func set_type(char_type:int, ability_type:int=0):
	isPlayer = (char_type == 0)
	ability = ability_type
	
	if(char_type == Global.char_type.PLAYER):
		current.iframes = 0
	else:
		base = enemy_lib.get_base_stats(ability)
		growth = enemy_lib.get_growth_stats(ability)
	
	current = base.duplicate()
	current.hp = current.max_hp


# update stats based on level
func update(emit=true):
	var old_max_hp = current["max_hp"]
	
	for stat in ["atk", "speed"]:
		current[stat] = calc_add(stat)
	for stat in ["max_hp", "max_exp"]:
		current[stat] = calc_mult(stat)
	current["atk_size"] = calc_add("atk_size", 0.01)
	
	heal(current["max_hp"] - old_max_hp, false)
	
	if emit: stats_updated.emit()
	

# Take damage
#var dmg_format : String = "{type} HP: {hp} (-{dmg})"
func take_damage(n:float):
	var dmg = 0
	var round_to # round to nearest 1 or 0.1
	
	if(!isPlayer):
		round_to = 1
	else: 
		round_to = 0.1
		
	# if player, set iframes after taking damage
	# if iframes is not 0, set damage to 0
	if isPlayer && current.iframes==0: 
		current.iframes = base.iframes
	else: if current.iframes != 0: n=0
	
	dmg = snapped(n * current.dmg_taken, 1)
	current.hp = snapped(current.hp-dmg, round_to) 
	
	if current.hp < 0: current.hp = 0

		
# Add levels 
func gain_level(n:int=1):
	current.level += n;
	update()
	
# Gain exp and levels
func gain_exp(n:float):
	current.exp += n
	
	var levels = 0
	while current.exp >= current.max_exp:
		levels+=1
		current.exp -= current.max_exp
		current.max_exp *= growth.max_exp
	
	gain_level(levels)

func heal(n:int, update_stats:bool=true):
	current.hp += n;
	if(current.hp > current.max_hp):
		current.hp = current.max_hp
	if update_stats: update()

# calculate stat based on level
func calc_add(stat:String, round_to:float=1.0, base_stats:Dictionary=base, growth_stats:Dictionary=growth, level:int=current.level):
	return snapped(base_stats[stat] + growth_stats[stat] * (level-1), round_to)

func calc_mult(stat:String, round_to:float=1.0, base_stats:Dictionary=base, growth_stats:Dictionary=growth, level:int=current.level):
	return snapped(floor(base_stats[stat] * pow(growth_stats[stat], level-1)), round_to)

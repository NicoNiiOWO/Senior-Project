class_name Character
extends CharacterBody2D
# Shared script for player and enemies

signal damage_taken()
signal defeated()

const effects_lib = preload("res://libraries/char_lib.gd")
const enemy_lib = preload("res://libraries/enemy_lib.gd")

var type : int # player or enemy

# Stats
# Enemy stats defined in enemy_lib
@export var base_stats : Dictionary = {
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
@export var stat_growth : Dictionary = {
	max_hp = 5,
	atk = 1.5,
	max_exp = 1.2, # multiply
	speed = 1,
	atk_size = 0.02
}

# Current stats
@export var stats : Dictionary = {} 
@onready var effects : Dictionary = effects_lib.init_effects()

@onready var main : Node = $/root/Main
@onready var gui : CanvasLayer = $/root/Main/GUI

# set stats based on character type
var isPlayer : bool = (type == 0)
func init(char_type:int, ability:int=0):
	type = char_type
	isPlayer = (type == 0)
	
	if(char_type == Global.char_type.PLAYER):
		stats.iframes = 0
	else:
		base_stats = enemy_lib.get_base_stats(ability)
		stat_growth = enemy_lib.get_growth_stats(ability)
	
	stats = base_stats.duplicate()
	stats.hp = stats.max_hp
	
	effects = effects_lib.init_effects()

# Take damage
var dmg_format : String = "{type} HP: {hp} (-{dmg})"
func take_damage(n:float):
	var dmg = 0
	var round_to # round to nearest 1 or 0.1
	
	if(!isPlayer):
		round_to = 1
	else: 
		round_to = 0.1
		
	# if player, set iframes after taking damage
	# if iframes is not 0, set damage to 0
	if isPlayer && stats.iframes==0: 
		stats.iframes = base_stats.iframes
	else: if stats.iframes != 0: n=0
	
	dmg = snapped(n * stats.dmg_taken, 1)
	stats.hp = snapped(stats.hp-dmg, round_to) 
	#print_debug(dmg_format.format({type = Global.char_type_str[type], hp=stats.hp, dmg=dmg}))
	
	if stats.hp <= 0:
		stats.hp = 0
		defeated.emit()
		
	# update hud if player
	if isPlayer: 
		Global.player_stats.hp = stats.hp
		gui.update_stats()
	
	
	damage_taken.emit()
	

# Add levels and update stats
func gain_level(n:int):
	stats.level += n;
	update_stats()

# Calculate stats and update hud
func update_stats():
	var current_max_hp = stats.max_hp
	
	for stat in ["max_hp", "atk", "speed"]:
		stats[stat] = stat_calc_add(stat)
	stats["atk_size"] = stat_calc_add("atk_size", 0.01)
	stats["max_exp"] = stat_calc_mult("max_exp")
	
	update_effects()
	# update stats
	for stat in effects.total_mod.keys():
		stats[stat] *= 1+effects.total_mod[stat]
	
	stats.hp += stats.max_hp - current_max_hp
	
	if(isPlayer):
		Global.player_stats = stats
		gui.update_stats()

# calculate stat based on level
func stat_calc_add(stat:String, round:float=1.0, base:Dictionary=base_stats, growth:Dictionary=stat_growth, level:int=stats.level):
	return snapped(base[stat] + growth[stat] * (level-1), round)

func stat_calc_mult(stat:String, round:float=1.0, base:Dictionary=base_stats, growth:Dictionary=stat_growth, level:int=stats.level):
	return snapped(floor(base[stat] * pow(growth[stat], level-1)), round)

func update_effects():
	effects_lib.set_stat_mod(effects)

func set_invincible(enable:bool):
	if enable: stats.iframes = -1
	else: stats.iframes = 0

# make invisible and disable processing
func disable():
	visible = false
	set_process_mode(PROCESS_MODE_DISABLED)

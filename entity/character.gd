class_name Character
extends CharacterBody2D
# Shared script for player and enemies

signal damage_taken()
signal defeated()

const effects_lib = preload("res://libraries/effects.gd")

var type : int # player or enemy

# Stats
@export var base_stats : Dictionary = {
	player = {
		level = 1,
		max_exp = 100,
		exp = 0,
		max_hp = 100,
		atk = 10,
		speed = 250,
		iframes = 0.25, # invincibility frames in seconds
		atk_size = 1, # attack size multiplier
		dmg_taken = 1, # damage taken multiplier
	},
	enemy = {
		level = 1,
		max_exp = 20, # exp given to player
		max_hp = 50,
		atk = 10,
		speed = 100,
		dmg_taken = 1,
	}
}
# Stat increase per level
@export var stat_growth : Dictionary = {
	player = {
		max_hp = 5,
		atk = 1.5,
		max_exp = 1.2, # multiply
		speed = 1,
		atk_size = 0.02
	},
	enemy = {
		max_hp = 5,
		atk = 2,
		max_exp = 1.15, # multiply
		speed = 2
	}
}

#enum calc {ADD,MULT} # stat calculation type

# Current stats
@export var stats : Dictionary = {} 
@export var effects : Dictionary = {
	weather = [],
}

@onready var main : Node = $/root/Main
@onready var gui : CanvasLayer = $/root/Main/GUI

# set stats based on character type
var isPlayer : bool = (type == 0)
func init(char_type:int):
	type = char_type
	isPlayer = (type == 0)
	
	if(char_type == Global.char_type.PLAYER):
		base_stats = base_stats.player
		stat_growth = stat_growth.player
		stats.iframes = 0
	else:
		base_stats = base_stats.enemy
		stat_growth = stat_growth.enemy
	
	stats = base_stats.duplicate()
	stats.hp = stats.max_hp

# Take damage
var dmg_format : String = "{type} HP: {hp} (-{dmg})"
func take_damage(n:float):
	var dmg = 0
	var round_to # round to nearest 1 or 0.1
	
	if(!isPlayer):
		round_to = 1
	else: 
		round_to = 0.1
		
		# if player iframes is not 0, set damage to 0
		if stats.iframes==0: 
			stats.iframes = base_stats.iframes
		else: n=0
	
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
		stats[stat] = stats_additive(stat)
	stats.max_exp = stats_multiplicative("max_exp")
	
	update_effects()
	stats.hp += stats.max_hp - current_max_hp
	
	if(isPlayer):
		stats.atk_size = stats_additive("atk_size")
		Global.player_stats = stats
		gui.update_stats()
		
	#print_debug(stats, effects)

# calculate stat based on level
func stats_additive(stat:String, base:Dictionary=base_stats, growth:Dictionary=stat_growth, level:int=stats.level):
	return snapped(base[stat] + growth[stat] * (level-1), 1) # nearest int

func stats_multiplicative(stat:String, base:Dictionary=base_stats, growth:Dictionary=stat_growth, level:int=stats.level):
	return snapped(floor(base[stat] * pow(growth[stat], level-1)), 1) # nearest int

func update_effects():
	effects_lib.update_effects(effects, stats)

# make invisible and disable processing
func disable():
	visible = false
	set_process_mode(PROCESS_MODE_DISABLED)

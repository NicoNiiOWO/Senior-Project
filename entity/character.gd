class_name Character
extends CharacterBody2D
# Shared script for player and enemies

signal damage_taken()
signal defeated()

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
		atk = 1.25,
		max_exp = 1.2, # multiply
		speed = 1,
		atk_size = 0.02
	},
	enemy = {
		max_hp = 5,
		atk = 2,
		max_exp = 1.1, # multiply
		speed = 2
	}
}

enum calc {ADD,MULT} # stat calculation type
@export var weather_effects : Dictionary = { # stats
	clear = {
		"atk": 0.2,
	},
	clouds = {},
	rain = {
		"atk": -0.1,
		"speed": -0.2,
	},
	snow = {
		"speed": -0.2,
		"dmg_taken": -0.2
	},
	storm = {
		"max_hp": -0.1,
		"atk": 0.3,
		"speed": 0.1
	},
	wind = {
		"atk": -0.2,
		"speed": 0.3
	}
}

# Current stats
@export var stats : Dictionary = {} 
@export var effects : Dictionary = {
	weather = [],
}

@onready var main : Node = $/root/Main
@onready var gui : CanvasLayer = $/root/Main/GUI

# set stats based on character type
var isPlayer : bool = (type == 0)
func init(char_type):
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
func take_damage(n):
	var dmg = 0
	var round # round to nearest 1 or 0.1
	
	if(!isPlayer):
		dmg = snapped(n * stats.dmg_taken, 1)
		round = 1
	else: 
		# player takes damage if iframes is 0
		if isPlayer && stats.iframes==0: 
			dmg = snapped(n * stats.dmg_taken, 0.1)
			round = 0.1
			stats.iframes = base_stats.iframes
	
	
	stats.hp = snapped(stats.hp-dmg, 0.1) 
	print_debug(dmg_format.format({type = Global.char_type_str[type], hp=stats.hp, dmg=dmg}))
	
	if stats.hp <= 0:
		stats.hp = 0
		defeated.emit()
		
	# update hud if player
	if isPlayer: 
		Global.player_stats.hp = stats.hp
		gui.update_stats()
		
	damage_taken.emit()
	

# Add levels and update stats
func gain_level(n):
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
func stats_additive(stat, base=base_stats, growth=stat_growth, level=stats.level):
	return snapped(base[stat] + growth[stat] * (level-1), 1) # nearest int

func stats_multiplicative(stat, base=base_stats, growth=stat_growth, level=stats.level):
	return snapped(floor(base[stat] * pow(growth[stat], level-1)), 1) # nearest int

func update_effects():
	effects.weather = []
	effects.total = {}
	#print_debug(Global.weather_data)
	if(Global.api_success && Global.weather_data.has("type")):
		# add effects based on weather type
		for type in Global.weather_data.type:
			effects.weather.append(weather_effects[type])
		
		# calculate total modifier
		var total = {}
		if(effects.weather.size() > 0):
			for effect in effects.weather:
				for key in effect.keys():
					if(total.has(key)): total[key] += (effect[key])
					else: total[key] = effect[key]
		
		effects.total=total
		
		# update stats
		for stat in total.keys():
			stats[stat] *= 1+total[stat]
		
		#print_debug(effects)

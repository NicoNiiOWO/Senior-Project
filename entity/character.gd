class_name Character
extends CharacterBody2D
# Shared script for player and enemies

signal damage_taken()
signal defeated()

var type # player or enemy

# Stats
@export var base_stats = {
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
@export var stat_growth = {
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
		max_exp = 1.05, # multiply
		speed = 2
	}
}

enum calc {ADD,MULT} # stat calculation type
@export var weather_effects = { # multiply stats
	clear = {
		"atk": 1.2,
	},
	clouds = {},
	rain = {
		"atk": 0.9,
		"speed": 0.8,
	},
	snow = {
		"speed": 0.8,
		"dmg_taken": 0.8
	},
	storm = {
		"max_hp": 0.9,
		"atk": 1.3,
		"speed": 1.1
	},
	wind = {
		"atk": 0.8,
		"speed": 1.3
	}
}

# Current stats
@export var stats = {} 
@export var effects = {
	weather = [],
}

@onready var main = $/root/Main
@onready var gui = $/root/Main/GUI

# set stats based on character type
var isPlayer = (type == 0)
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
func take_damage(n):
	# player takes damage if iframes is 0
	if(isPlayer):
		if(stats.iframes == 0):
			stats.hp -= n * stats.dmg_taken
			stats.iframes = base_stats.iframes
			print("Player HP: ", stats.hp)
	else: 
		stats.hp -= n * stats.dmg_taken
		if(stats.hp < 1 && stats.hp > 0): stats.hp = 0
		print("Enemy HP: ", stats.hp)
	
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
		
	print(stats, effects)

# calculate stat based on level
func stats_additive(stat, base=base_stats, growth=stat_growth, level=stats.level):
	return base[stat] + growth[stat] * (level-1)

func stats_multiplicative(stat, base=base_stats, growth=stat_growth, level=stats.level):
	return floor(base[stat] * pow(growth[stat], level-1))

func update_effects():
	effects.weather = []
	effects.total = {}
	print(Global.weather_data)
	if(Global.api_success && Global.weather_data.has("type")):
		# add effects based on weather type
		for type in Global.weather_data.type:
			effects.weather.append(weather_effects[type])
		
		# calculate total modifier
		var total = {}
		if(effects.weather.size() > 0):
			for effect in effects.weather:
				for key in effect.keys():
					if(total.has(key)): total[key] += (effect[key]-1)
					else: total[key] = effect[key]
		
		effects.total=total
		
		# update stats
		for stat in total.keys():
			stats[stat] *= total[stat]
		
		print(effects)

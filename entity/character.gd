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
	},
	enemy = {
		level = 1,
		max_exp = 20, # exp given to player
		max_hp = 50,
		atk = 10,
		speed = 100,
	}
}
# Stat increase per level
@export var stat_growth = {
	player = {
		max_hp = 5,
		atk = 1.25,
		max_exp = 1.2, # multiply
		speed = 1,
		atk_size = 0.05
	},
	enemy = {
		max_hp = 5,
		atk = 2,
		max_exp = 1.1, # multiply
		speed = 2
	}
}
var effects = []

# Current stats
@export var stats = {} 

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
			stats.hp -= n
			stats.iframes = base_stats.iframes
			print("Player HP: ", stats.hp)
	else: 
		stats.hp -= n
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
	stats.hp += stats.max_hp - current_max_hp
	stats.max_exp = stats_multiplicative("max_exp")
	
	if(isPlayer):
		stats.atk_size = stats_additive("atk_size")
		Global.player_stats = stats
		gui.update_stats()
		
	print(stats)

func stats_additive(stat):
	return base_stats[stat] + stat_growth[stat] * (stats.level-1)

func stats_multiplicative(stat):
	return floor(base_stats[stat] * pow(stat_growth[stat], (stats.level-1)))

class_name Character
extends CharacterBody2D
# Shared script for player and enemies

signal defeated()

var type

# Stats

@export var base_stats = {
	player = {
		level = 1,
		max_exp = 100,
		exp = 0,
		max_hp = 100,
		atk = 10,
		speed = 250,
		iframes = 0.25 # invincibility frames in seconds
	},
	enemy = {
		level = 1,
		exp = 20,
		max_hp = 50,
		atk = 10,
		speed = 100,
	}
}
# Stat increase per level
@export var stat_growth = {
	player = {
		max_hp = 5,
		atk = 2,
		max_exp = 1.1
	}
}

# Current stats
@export var stats = {} 

@onready var main = $/root/Main
@onready var gui = $/root/Main/GUI

# set stats based on character type
func init(char_type):
	type = char_type
	if(char_type == Global.char_type.PLAYER):
		base_stats = base_stats.player
		stat_growth = stat_growth.player
		stats.iframes = 0
	else:
		base_stats = base_stats.enemy
	stats = base_stats.duplicate()
	stats.hp = stats.max_hp

# Take damage
func take_damage(n):
	var isPlayer = (type == 0)
	
	# player takes damage if iframes is 0
	if(isPlayer):
		if(stats.iframes == 0):
			stats.hp -= n
			stats.iframes = base_stats.iframes
			print(stats.iframes," ", base_stats.iframes)
	else: 
		stats.hp -= n
	
	if stats.hp <= 0:
		stats.hp = 0
		defeated.emit()
		
	# update hud if player
	if isPlayer: 
		Global.player_stats.hp = stats.hp
		gui.update_hud()
		
	print("HP: ", stats.hp)

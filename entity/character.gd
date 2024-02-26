class_name Character
extends CharacterBody2D
# Shared script for player and enemies

signal defeated()

var type

# Stats

@export var base_stats = {
	player = {
		max_hp = 100,
		atk = 10,
		speed = 300,
		max_exp = 100
	},
	enemy = {
		max_hp = 50,
		atk = 10,
		speed = 100,
		exp = 20
	}
}
# Stat increase per level
@export var stat_growth = {
	player = {
		max_hp = 5,
		atk = 2,
		max_exp = 10
	}
}

# Current stats
@export var stats = {
	level = 1,
	max_exp = 0,
	exp = 0,
	max_hp = 0,
	hp = 0,
	atk = 0,
	speed = 0
} 

# set stats based on character type
func init(char_type):
	type = char_type
	if(char_type == Global.char_type.PLAYER):
		base_stats = base_stats.player
		stat_growth = stat_growth.player
		
		stats.max_hp = base_stats.max_hp
		stats.atk = base_stats.atk
		stats.speed = base_stats.speed
		stats.max_exp = base_stats.max_exp
	else:
		base_stats = base_stats.enemy
		
		stats.max_hp = base_stats.max_hp
		stats.atk = base_stats.atk
		stats.speed = base_stats.speed
		stats.exp = base_stats.exp
	stats.hp = stats.max_hp

# Take damage
func take_damage(n):
	stats.hp -= n;
	if stats.hp <= 0:
		stats.hp = 0
		defeated.emit()
	print("HP: ", stats.hp)

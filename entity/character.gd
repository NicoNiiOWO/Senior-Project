class_name Character
extends CharacterBody2D
# Shared script for player and enemies

signal defeated()

enum types {PLAYER, ENEMY}
var type

# Stats

@export var base_stats = {
	player = {
		max_exp = 100,
		max_health = 50,
		atk = 10,
		speed = 300
	},
	enemy = {
		max_exp = 50,
		max_health = 50,
		atk = 10,
		speed = 100
	}
}
@export var level = 1
@export var max_exp = 100
@export var exp = 0
@export var max_health = 50
@export var atk = 10
@export var speed = 300

var health = max_health

func _init():
	print(self.get_name())

# Take damage
func take_damage(n):
	health -= n;
	if health <= 0:
		health = 0
		defeated.emit()
	print("HP: ", health)

# Gain exp and level
func gain_exp(n):
	exp += n
	while exp >= max_exp:
		level+=1
		exp -= max_exp
		
func update_stats():
	pass

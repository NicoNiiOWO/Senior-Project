class_name Attack
extends Area2D

@export var duration : float = 0.25 # How long attack lasts
@export var damage : float = 10
@export var size : float = 1 # size multiplier
var source : int # source of attack (player/enemy)
var direction : Vector2 # attack direction

@onready var sprite = $AnimatedSprite2D


func init_attack(direction:Vector2, atk_source:int, dmg:float, size_m:float = 1):
	source = atk_source
	damage = dmg
	size = size_m
	
	self.direction = direction
	global_rotation = Vector2.ZERO.angle_to_point(direction)

func _on_timer_timeout():
	queue_free() # Remove from memory 

func _on_body_entered(body):
	if(body.has_method("take_damage")):
		if(body.type != source): # check source of attack
			body.take_damage(damage)

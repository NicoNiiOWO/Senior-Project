class_name Attack
extends Area2D

signal attack_end

@export var duration : float = 0.25 # How long attack lasts
@export var damage : float = 10
@export var size : float = 1.0 # size multiplier
@export var source : int # source of attack (player/enemy)

@onready var timer = $Timer
@onready var sprite = $AnimatedSprite2D


func init_attack(atk_source:int, dmg:float, size_m:float = 1.0, dur:float=0.25):
	source = atk_source
	damage = dmg
	size = size_m
	duration = dur

func start():
	#timer.timeout.connect(_on_timer_timeout)
	sprite.play()
	timer.wait_time = duration
	timer.start()
	global_scale *= size

func _on_timer_timeout():
	delete()

func delete():
	attack_end.emit()
	queue_free() # Remove from memory 

func _on_body_entered(body):
	print(body)
	if(is_instance_of(body, Character)):
		if(body.type != source): # check source of attack
			body.take_damage(damage)

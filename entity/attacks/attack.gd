class_name Attack
extends Area2D

signal attack_end

@export var duration : float = -1 # How long attack lasts, -1 for no timer
@export var damage : float = 10
@export var size : float = 1.0 # size multiplier
@export var source : int = 0 # source of attack (player/enemy)
@export var direction : Vector2 = Vector2.RIGHT # attack direction

@onready var timer : Timer = $Timer
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

var isAbility : bool = false


func init_attack(atk_source:int=source, dmg:float=damage, size_m:float = size, dur:float=duration):
	source = atk_source
	damage = dmg
	size = size_m
	duration = dur

func set_source(atk_source:int=0): source = atk_source
func set_damage(dmg:float): damage = dmg
func set_size(size_m:float): size = size_m
func set_duration(dur:float): duration = dur
func set_direction(dir:Vector2, rotate_sprite:bool=true):
	direction = dir
	
	if rotate_sprite:
		rotation = Vector2.ZERO.angle_to_point(direction)

# start animation and timer
func start():
	#timer.timeout.connect(_on_timer_timeout)
	sprite.play()
	if duration != -1:
		timer.wait_time = duration
		timer.start()
	else: timer.paused = true
	global_scale *= size

func _on_timer_timeout():
	delete()

func delete():
	attack_end.emit()
	queue_free() # Remove from memory 

func _on_body_entered(body):
	if(is_instance_of(body, Character)):
		if(body.type != source): # check source of attack
			body.take_damage(damage, isAbility)

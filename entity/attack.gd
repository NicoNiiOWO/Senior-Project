extends Area2D

@export var duration : float = 0.25 # How long attack lasts
@export var damage : float = 10
@export var size : float = 1 # size multiplier
var source : int # source of attack (player/enemy)

func init(atk_source:int, dmg:float, size_m:float):
	source = atk_source
	damage = dmg
	size = size_m

# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = $Timer
	timer.wait_time = duration
	global_scale *= size

func _on_timer_timeout():
	queue_free() # Remove from memory 

func _on_body_entered(body):
	if(body.has_method("take_damage")):
		if(body.type != source): # check source of attack
			body.take_damage(damage)

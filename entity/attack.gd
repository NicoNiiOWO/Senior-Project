extends Area2D

@export var duration = 0.25 # How long attack lasts
@export var damage = 10
@export var size = 1 # size multiplier
var source # source of attack (player/enemy)

func init(atk_source, dmg, size_m):
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

extends Attack

func init(atk_source:int, dmg:float, size_m:float = 1, duration:float=2.0):
	init_attack(atk_source, dmg, size_m, duration)

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()
	$Timer.wait_time = duration
	$Timer.start()
	global_scale *= size


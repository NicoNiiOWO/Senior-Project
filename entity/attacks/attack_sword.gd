extends Attack

func init(direction:Vector2, atk_source:int, dmg:float, size_m:float = 1, a:int=1):
	init_attack(direction, atk_source, dmg, size_m)
	position += direction*30 + Vector2(0, -5)

# Called when the node enters the scene tree for the first time.
func _ready():
	# set animation
	if source == 0:
		sprite.play("player")
	else:
		sprite.play("enemy")
		sprite.scale = Vector2(1.7,1.7)
	
	# flip sprite
	if direction.x < 0: sprite.flip_v = true
	
	# set duration
	var timer = $Timer
	timer.wait_time = duration
	global_scale *= size

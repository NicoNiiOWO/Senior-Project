extends Attack

func init(dir:Vector2, atk_source:int, dmg:float, size_m:float = 1.0, dur = 0.25):
	init_attack(atk_source, dmg, size_m, dur)
	
	# offset position and change rotation
	position += dir*30 + Vector2(0, -5)
	set_direction(dir)

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
	
	start()

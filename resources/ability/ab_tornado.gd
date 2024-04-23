extends Ability

const attack_scn = preload("res://entity/attacks/proj_tornado.tscn")
var radius = 120

var projectiles : Array = [] # store current attack nodes

func on_level_changed():
	super.on_level_changed()
	add_attack(int(level/3) +1)

# add attacks rotated evenly
func add_attack(count:int=1):
	clear()
	if count == 0: count=1
	
	var rotation = 2*PI/count
	
	for i in range(count):
		var atk = init_attack(attack_scn) as Projectile
		
		atk.orbit(radius)
		atk.position = atk.position.rotated(i*rotation)
		
		projectiles.append(atk)
		parent.add_child(atk)

func clear():
	for proj in projectiles:
		proj.queue_free()
	
	projectiles = []

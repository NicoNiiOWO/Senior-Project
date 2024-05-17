extends Ability

const attack_scn = preload("res://entity/attacks/proj_tornado.tscn")
var radius = 120

var max_count = 4

var projectiles : Array = [] # store current attack nodes

func _init(): name = "Tornado"
func on_level_changed():
	super.on_level_changed()
	add_attack(int(level/3) +1)

# add attacks rotated evenly
func add_attack(count:int=1):
	if count == 0: count=1
	if count > max_count: 
		count = max_count
		update_attacks()
	else:
		clear()
		var rotation = 2*PI/count
		
		for i in range(count):
			var atk = init_attack(attack_scn) as Projectile
			
			atk.isAbility = true
			
			atk.orbit(radius)
			atk.position = atk.position.rotated(i*rotation)
			
			projectiles.append(atk)
			parent.call_deferred("add_child", atk)

func update_attacks():
	for atk in projectiles:
		atk_update_stats(atk)

func clear():
	for proj in projectiles:
		proj.queue_free()
	
	projectiles = []

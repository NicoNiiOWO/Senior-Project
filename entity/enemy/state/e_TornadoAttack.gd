extends Node

var attack_scn : PackedScene = preload("res://entity/attacks/tornado.tscn")

enum phase {NONE=-1, START, ACTIVE, END} # attack states
@export var duration : Array = [2.0, 2.0, 2.0] # duration of each state
@export var speed_mod : Array = [0.5, 2.2, 0.3] # speed for each state

var attack_startup : bool = false

var spd_mod = 1
func physics_process():
	# increase animation speed during startup
	if(attack_startup):
		owner.sprite.speed_scale += 0.05
		
	# if near player, dont change direction
	if owner.global_position.distance_to(owner.target.global_position) > 70:
		owner.move(spd_mod)
	

func attack():
	# change speed
	spd_mod = speed_mod[phase.START]
	attack_startup = true
	await get_tree().create_timer(duration[phase.START]).timeout
	
	# add attack
	attack_start()
	
	# wait until attack ends
	await get_tree().create_timer(duration[phase.ACTIVE]).timeout
	attack_end()

func attack_start():
	# hide sprite, reset animation speed, make invincible
	attack_startup = false
	owner.sprite.speed_scale = 1
	owner.sprite.hide()
	owner.set_invincible(true)
	
	# add attack, increase speed
	var attack = attack_scn.instantiate()
	attack.init(1,owner.stats.atk, owner.stats.atk_size, duration[phase.ACTIVE])
	owner.add_child(attack)
	spd_mod = speed_mod[phase.ACTIVE]
	
func attack_end():
	# slow
	owner.sprite.show()
	owner.set_invincible(false)
	spd_mod = speed_mod[phase.END]
	
	await get_tree().create_timer(duration[phase.END]).timeout
	spd_mod = 1
	owner.attack(false)

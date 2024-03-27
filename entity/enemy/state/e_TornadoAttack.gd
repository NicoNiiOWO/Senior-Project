extends Node

var attack_scn : PackedScene = preload("res://entity/attacks/tornado.tscn")

@export var startup : float = 2.0 # startup time
@export var duration : float = 2.0 
@export var cooldown_time : float = 1.0

var attack_startup : bool = false
var attack_endlag : bool = false

var spd_mod = 1
func physics_process():
	# move if not in endlag
	if attack_endlag: 
		spd_mod = 0
		
	# increase animation speed during startup
	if(attack_startup):
		owner.sprite.speed_scale += 0.05
	
	owner.move(spd_mod)
	

func attack():
	# change speed
	spd_mod = 0.5
	attack_startup = true
	await get_tree().create_timer(startup).timeout
	
	# add attack
	attack_start()
	
	# wait until attack ends
	await get_tree().create_timer(duration).timeout
	attack_end()

func attack_start():
	# hide sprite, reset animation speed, make invincible
	attack_startup = false
	owner.sprite.speed_scale = 1
	owner.sprite.hide()
	owner.set_invincible(true)
	
	# add attack, increase speed
	var attack = attack_scn.instantiate()
	attack.init(1,owner.stats.atk, owner.stats.atk_size, duration)
	owner.add_child(attack)
	spd_mod = 1.8
	
func attack_end():
	attack_endlag = true
	
	owner.sprite.show()
	owner.set_invincible(false)
	
	
	spd_mod = 0.8
	await get_tree().create_timer(cooldown_time).timeout
	attack_endlag = false
	owner.sprite.play("walk")
	spd_mod = 1
	owner.attack(false)

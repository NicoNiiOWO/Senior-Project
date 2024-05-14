extends Node

var attack_scn : PackedScene = preload("res://entity/attacks/tornado.tscn")

enum phase {NONE=-1, START, ACTIVE, END} # attack states
@export var duration : Array = [2.0, 2.0, 2.0] # duration of each state
@export var speed_mod : Array = [0.5, 2.0, 0.3] # speed for each state
@export var dmg_mod : Array = [-0.5, .5] # damage taken for active/end

var current_phase : int = phase.NONE
var sound = null

var spd_mod = 1
func physics_process():
	# increase animation speed during startup
	if current_phase == phase.START:
		owner.sprite.speed_scale += 0.05
	
	if current_phase == phase.ACTIVE:
		owner.move(spd_mod, 0.03)
	else:
		owner.move(spd_mod)

func attack():
	if sound == null:
		sound = get_parent().get_parent().get_node_or_null("Sound/Tornado") as AudioStreamPlayer2D
	
	# change speed
	current_phase = phase.START
	spd_mod = speed_mod[phase.START]
	
	await get_tree().create_timer(duration[phase.START], false).timeout
	
	# add attack
	attack_start()
	
	# wait until attack ends
	await get_tree().create_timer(duration[phase.ACTIVE], false).timeout
	attack_end()

func attack_start():
	if sound != null: sound.play()
	# hide sprite, reset animation speed, make invincible
	current_phase = phase.ACTIVE
	owner.sprite.speed_scale = 1
	owner.sprite.hide()
	owner.stats.dmg_taken += dmg_mod[0]
	#owner.set_invincible(true)
	
	# add attack, increase speed
	var new_attack = attack_scn.instantiate()
	new_attack.init(1,owner.stats.atk*2, owner.stats.atk_size, duration[phase.ACTIVE])
	owner.add_child(new_attack)
	spd_mod = speed_mod[phase.ACTIVE]
	
func attack_end():
	if sound != null: sound.stop()
	# show sprite, change speed
	current_phase = phase.END
	owner.sprite.show()
	#owner.set_invincible(false)
	
	owner.stats.dmg_taken += (-dmg_mod[0]) + dmg_mod[1]
	spd_mod = speed_mod[phase.END]
	owner.sprite.speed_scale = 0.7
	
	# after delay, set back to normal
	await get_tree().create_timer(duration[phase.END], false).timeout
	current_phase = phase.NONE
	owner.sprite.speed_scale = 1
	owner.stats.dmg_taken -= dmg_mod[1]
	spd_mod = 1
	owner.attack(false)

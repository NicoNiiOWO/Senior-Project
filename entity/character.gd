class_name Character
extends CharacterBody2D
# Shared script for player and enemies

signal damage_taken(dmg, isAbility, playSound)
signal defeated()
signal attack_start(x)

var type : int # player or enemy

@export var stats_r : Stats
@export var stats : Dictionary = {}: set = _set_stats, get = _get_stats # alias for current stats in resource

func _set_stats(new_stats):
	stats_r.current = new_stats

func _get_stats():
	return stats_r.current

# @onready var effects : Dictionary = char_lib.init_effects().duplicate(true)
var effects : EffectList = EffectList.new().init(self)

@onready var main : Node = $/root/Main
@onready var gui : CanvasLayer = $/root/Main/GUI

# set stats based on character type
var isPlayer : bool = (type == 0)
func init(char_type:int, ability:int=0):
	type = char_type
	isPlayer = (type == 0)
	
	stats_r = Stats.new()
	stats_r.set_type(type, ability)
	stats = stats_r.current
	
	stats_r.stats_updated.connect(_on_stats_updated)

func _ready(): # set default
	if type == null:
		init(0)

# Take damage
const damage_num_scn = preload("res://resources/damage_number.tscn")
func take_damage(n:float, isAbility:bool=false, playSound:bool=true):
	var dmg = stats_r.take_damage(n)
	if dmg > 0: 
		damage_taken.emit(dmg, isAbility, playSound)
		
		# show damage number
		var dmg_n = damage_num_scn.instantiate()
		dmg_n.dmg = dmg
		
		dmg_n.position = position
		get_parent().add_child(dmg_n)
	
	
	if stats.hp <= 0:
		stats.hp = 0
		defeated.emit()
		
	# update hud if player
	if isPlayer: 
		#Global.player_stats.hp = stats.hp
		gui.update_stats()

# Add levels and update stats
func gain_level(n:int=1):
	stats_r.gain_level(n)
	update_stats()

# Calculate stat effects and update hud
func update_stats():
	var current_max_hp = stats.max_hp
	
	stats_r.update(false)
	
	update_effects()
	# update stats
	for stat in effects.total_mod.keys():
		stats[stat] *= 1+effects.total_mod[stat]
	
	_on_stats_updated()

func _on_stats_updated():
	if stats.hp <= 0:
		defeated.emit()
	
	if(isPlayer):
		#Global.player_stats = stats
		gui.update_stats()


func update_effects():
	effects.update_total()

func set_invincible(enable:bool):
	if enable: stats.iframes = -1
	else: stats.iframes = 0

# make invisible and disable processing
func disable():
	visible = false
	set_process_mode(PROCESS_MODE_DISABLED)

func add_upgrade(upgrade:Upgrade):
	# char_lib.add_upgrade(effects, upgrade)
	effects.add_upgrade(upgrade)
	update_stats()

func has_upgrade(upgrade:Upgrade) -> bool:
	return effects.has_upgrade(upgrade)

# if has same type, return upgrade
func get_upgrade(upgrade:Upgrade) -> Upgrade:
	return effects.get_upgrade(upgrade)

func attack(atk:bool=true):
	attack_start.emit(atk)

extends Effect
class_name Upgrade

const upgrade_lib = preload("res://libraries/upgrade_lib.gd")

@export var ability:int = 0

#func set_upgrade_dict(abi:int, stat:Dictionary={}):
	#ability = abi
	#set_stats(stat)

func set_stat_upgrade(stat:String, count:int=1):
	ability = 0
	set_effect(effect_lib.get_upgrade(stat))
	add(count-1)

func set_ability_upgrade(ability_:int):
	ability = ability_
	
	set_effect(effect_lib.get_ability(ability_))

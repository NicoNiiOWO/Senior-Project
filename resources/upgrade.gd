extends Effect
class_name Upgrade

const upgrade_lib = preload("res://libraries/upgrade_lib.gd")

@export var ability:int = 0

var text:String = ""

func set_stat_upgrade(stat:String, count:int=1):
	ability = 0
	set_upgrade(effect_lib.get_upgrade(stat))
	add(count-1)

func set_ability_upgrade(ability_:int):
	ability = ability_
	
	set_upgrade(effect_lib.get_ability(ability_))

func set_upgrade(eff_data:Dictionary):
	set_effect(eff_data)
	text = upgrade_lib.get_text(self)

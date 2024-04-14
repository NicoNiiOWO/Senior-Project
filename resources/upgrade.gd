extends Resource
class_name Upgrade

#const upgrade_format = {
	#ability = 0,
	#node = null,
	#stats = {}
#}

@export var ability:int = 0
@export var stats:Dictionary = {}

#func _init(ability:int, stats:Dictionary={}):
	#set_upgrade(ability,stats)

func set_upgrade(abi:int, stat:Dictionary={}):
	ability = abi
	stats = stat


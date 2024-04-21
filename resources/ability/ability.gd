extends Upgrade
class_name Ability

var node : AbilityNode = null

func set_ability(ability_:int):
	ability = ability_
	
	set_upgrade(effect_lib.get_ability(ability_))
	get_node()

func get_node() -> AbilityNode:
	if node == null:
		node = upgrade_lib.get_node(self)
	return node

func physics_update(delta):
	pass

func on_attack():
	if node.active:
		node.attack()

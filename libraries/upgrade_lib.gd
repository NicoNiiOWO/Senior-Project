extends Resource

# list of stats that can be upgraded
const stats_upgradeable = ["atk","speed","max_hp","atk_size","dmg_taken"]

const path_format = {
	icon_text = "res://assets/Icons/Ability/a_{str}_text.tres",
	icon = "res://assets/Icons/Ability/a_{str}_icon.tres",
	item_icon = "res://assets/Icons/Ability/a_{str}_item.tres",
	script = "res://resources/ability/ab_{str}.gd",
}
const ability_data = {
	0 : {
		icon_text = preload("res://assets/Icons/Ability/a_normal_text.tres"),
		icon = preload("res://assets/Icons/Ability/a_normal_icon.tres"),
	},
	1 : {
		icon_text = preload("res://assets/Icons/Ability/a_sword_text.tres"),
		icon = preload("res://assets/Icons/Ability/a_sword_icon.tres"),
		item_icon = preload("res://assets/Icons/Ability/a_sword_item.tres"),
		script = preload("res://resources/ability/ab_sword.gd"),
		desc = "Add projectile on attack"
	},
	2 : {
		icon_text = preload("res://assets/Icons/Ability/a_tornado_text.tres"),
		icon = preload("res://assets/Icons/Ability/a_tornado_icon.tres"),
		item_icon = preload("res://assets/Icons/Ability/a_tornado_item.tres"),
		script = preload("res://resources/ability/ab_tornado.gd"),
		desc = "Add tornado"
	},
	3 : {
		icon_text = preload("res://assets/Icons/Ability/a_parasol_text.tres"),
		icon = preload("res://assets/Icons/Ability/a_parasol_icon.tres"),
		item_icon = preload("res://assets/Icons/Ability/a_parasol_item.tres"),
		script = preload("res://resources/ability/ab_parasol.gd"),
		desc = "Damage nearby enemies"
	}
}



static func make_stat_upgrade(stat:String, x:int=1) -> Upgrade:
	var upgrade = Upgrade.new()
	upgrade.set_stat_upgrade(stat, x)
	
	return upgrade

static func make_stat_upgrade_i(index:int, x:int=1) -> Upgrade:
	var stat = stats_upgradeable[index]
	return make_stat_upgrade(stat, x)

static func make_ability(ability:int, parent:Character = null) -> Ability:
	if ability == 0 or ability not in ability_data: 
		print_debug(ability)
		return null
	
	var upgrade = ability_data[ability].script.new()
	upgrade.init(ability, parent)
	return upgrade

# array of random upgradeable stats, no duplicates
static func rand_stats(count:int=1) -> Array:
	if count > stats_upgradeable.size():
		count = stats_upgradeable.size()
	
	var arr = []
	
	if count == 1:
		var x = randi_range(0,stats_upgradeable.size()-1)
		arr = [stats_upgradeable[x]]
	else:
		# copy array, randomly remove until x items
		arr = stats_upgradeable.duplicate()
		
		for i in range(stats_upgradeable.size()-count):
			var x = randi_range(0,arr.size()-1)
			arr.remove_at(x)
	
	return arr

# array of random upgrades
static func random_upgrade(ability=0, count:int=1, x:int=1) -> Array:
	if count > stats_upgradeable.size():
		count = stats_upgradeable.size()
	
	var upgrades = []
	
	match ability:
		-1: # each ability
			for i in range(1, ability_data.size()):
				upgrades.append(make_ability(i))
		0: # random stats
			var stats = rand_stats(count)
			
			for stat in stats:
				upgrades.append(make_stat_upgrade(stat,x))
		_:
			for i in range(count):
				upgrades.append(make_ability(ability))
	
	#print_debug(upgrades)
	return upgrades

static func get_text(upgrade:Upgrade) -> String:
	var text = ""
	
	# if no ability, use stats
	if upgrade.ability == 0 || upgrade.ability == -1:
		text += get_stat_text(upgrade.stats)
	else: if upgrade.ability in ability_data:
		text = ability_data[upgrade.ability].desc
	
	return text

static func get_stat_text(stats:Dictionary) -> String:
	var text = ""
	for stat in stats:
		var stat_mod = stats[stat]
		var num_sign
		if stat_mod > 0: num_sign = " +"
		else: num_sign = " "
		
		text += str(stat.capitalize(), num_sign, stat_mod*100, "%, ")
	if text.ends_with(", "): text = text.left(-2) # remove last space and comma
	return text

static func get_icons(upgrade:Upgrade) -> Dictionary:
	var ability = upgrade.ability
	return {
		text = ability_data[ability].icon_text,
		icon = ability_data[ability].icon,
	}

#static func get_ability_script(ability:Ability) -> Ability:
	#if ability.ability == 0: return null
	#
	#var script = ability_data[ability.ability].script.duplicate()
	#script.init(ability)
	#return script

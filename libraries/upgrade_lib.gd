extends Resource

# list of stats that can be upgraded
const stats_upgradeable = ["atk","speed","max_hp","atk_size","dmg_taken"]

const ability_icons = {
	0 : {
		text = preload("res://assets/Icons/Ability/a_normal_text.tres"),
		icon = preload("res://assets/Icons/Ability/a_normal_icon.tres")
	},
	1 : {
		text = preload("res://assets/Icons/Ability/a_sword_text.tres"),
		icon = preload("res://assets/Icons/Ability/a_sword_icon.tres")
	},
	2 : {
		text = preload("res://assets/Icons/Ability/a_tornado_text.tres"),
		icon = preload("res://assets/Icons/Ability/a_tornado_icon.tres")
	}
}

static func make_stat_upgrade(stat:String, x:int=1, ability=0) -> Upgrade:
	var upgrade = Upgrade.new()
	upgrade.set_stat_upgrade(stat)
	return upgrade

static func make_stat_upgrade_i(index:int, x:int=1) -> Upgrade:
	var stat = stats_upgradeable[index]
	return make_stat_upgrade(stat,x)

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
static func random_upgrade(count:int=1, x:int=1):
	if count > stats_upgradeable.size():
		count = stats_upgradeable.size()
		
	var stats = rand_stats(count)
	
	var upgrades = []
	for stat in stats:
		upgrades.append(make_stat_upgrade(stat,x))
	
	print_debug(upgrades)
	return upgrades

static func get_text(upgrade:Upgrade) -> String:
	var text = ""
	
	for stat in upgrade.stats:
		var stat_mod = upgrade.stats[stat]
		var sign
		if stat_mod > 0: sign = " +"
		else: sign = " "
		
		text += str(stat.capitalize(), sign, stat_mod*100, "%")
	
	return text

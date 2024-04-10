extends Resource

# list of stats that can be upgraded
const stats_upgradeable = ["atk","speed","max_hp","atk_size","dmg_taken"]

# base increase, in percent
const upgrade_base = 5

static func make_upgrade(stat:String, x:int=1):
	return {stat : upgrade_base*x}

static func make_upgrade_i(index:int, x:int=1):
	return {stats_upgradeable[index] : upgrade_base*x}

# array of random upgradeable stats, no duplicates
static func rand_stats(count:int=1) -> Array:
	if count > stats_upgradeable.size():
		count = stats_upgradeable.size()
	
	var arr = []
	
	if count == 1:
		var x = randi_range(0,stats_upgradeable.size())
		arr = [stats_upgradeable[x]]
	else:
		# copy array, randomly remove until x items
		arr = stats_upgradeable.duplicate()
		
		for i in range(stats_upgradeable.size()-count):
			var x = randi_range(0,arr.size())
			arr.remove_at(x)
	
	return arr

# array of random upgrades
static func random_upgrade(count:int=1, x:int=1):
	if count > stats_upgradeable.size():
		count = stats_upgradeable.size()
		
	var stats = rand_stats(count)
	
	var upgrades = []
	for stat in stats:
		upgrades.append(make_upgrade(stat,x))
	
	print_debug(upgrades)
	return upgrades

const text_f = "{Stat} +{Mod}%"
static func get_text(upgrade:Dictionary) -> String:
	var text = ""
	
	for stat in upgrade.keys():
		text += text_f.format({
			Stat = stat.capitalize(),
			Mod = upgrade[stat]
			})
	
	return text

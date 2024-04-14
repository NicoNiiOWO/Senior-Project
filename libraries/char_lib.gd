extends Resource

enum stats_type {ATK, SPEED, MAX_HP, DMG_TAKEN, ATK_SIZE}

enum category {WEATHER,UPGRADE,TOTAL}
enum weather_type {CLEAR, CLOUDS, RAIN, SNOW, STORM, WIND}

#const upgrade_s = preload("res://libraries/upgrade.gd")

#const upgrade_format = {
	#node = null,
	#stats = {}
#}

const effect_list : Dictionary = {
	category.WEATHER : { # stats
		weather_type.CLEAR : {
			"atk": 0.2,
		},
		weather_type.CLOUDS : {
			"speed":0.1,
		},
		weather_type.RAIN : {
			"atk": -0.1,
			"speed": -0.1,
		},
		weather_type.SNOW : {
			"speed": -0.1,
			"dmg_taken": -0.2,
			"atk_size": 0.2
		},
		weather_type.STORM : {
			"max_hp": -0.1,
			"atk": 0.3,
			"speed": 0.1
		},
		weather_type.WIND : {
			"atk": -0.2,
			"speed": 0.3
		}
	},
	category.UPGRADE : {
		"list":[],
		"total":{
			"max_hp": 0,
			"atk": 0,
			"speed": 0,
			"dmg_taken": 0,
			"atk_size": 0,
		}
	}
}



static func init_effects() -> Dictionary:
	var effects = {
		# list of individual effects
		category.WEATHER: {},
		category.UPGRADE: effect_list[category.UPGRADE].duplicate(),
		category.TOTAL: {} # total stat changes
	}
	return effects

# add effect to input dictionary
static func add_effect(effects:Dictionary, eff_category:int, eff_type:int) -> void:
	if !effects[eff_category].has(eff_type):
		effects[eff_category][eff_type] = effect_list[eff_category][eff_type]

static func add_upgrade(effects:Dictionary, upgrade:Upgrade):
	effects[category.UPGRADE]["list"].append(upgrade)

# add stat upgrade
static func add_stat_upgrade(effects:Dictionary, stat:String, n:float) -> void:
	add_upgrade_dict(effects, {stat:n})

# add upgrade from stat dict
static func add_upgrade_dict(effects:Dictionary, stats:Dictionary, node:Node=null) -> void:
	var upgrade = Upgrade.new()
	upgrade.stats = stats
	
	if node != null: upgrade.node = node
	
	# add upgrade, add stats to total
	effects[category.UPGRADE]["list"].append(upgrade)
	effects[category.TOTAL] = get_total_stat(effects)
	

static func get_upgrade_stat(upgrade_list:Array) -> Dictionary:
	var total = {}
	for upgrade in upgrade_list:
		for stat in upgrade.stats.keys():
			add_stat(total, stat, upgrade.stats[stat])
	
	return total
# return total stat mod from dictionary
static func get_total_stat(effects:Dictionary) -> Dictionary:
	var weather_total = {}
	
	# loop through weather and upgrade categories
	for weather in effects[0]:
		#print_debug(effect)
		for stat in effects[0][weather]:
			add_stat(weather_total, stat, effects[0][weather][stat])
	
	var upgrade_total = get_upgrade_stat(effects[category.UPGRADE]["list"])
	effects[category.UPGRADE]["total"] = upgrade_total
	
	
	return combine_stat_dict(weather_total, upgrade_total)

static func combine_stat_dict(dict1:Dictionary, dict2:Dictionary) -> Dictionary:
	var combined = dict1.duplicate()
	
	for stat in dict2.keys():
		add_stat(combined, stat, dict2[stat])
	
	return combined

static func add_stat(stats:Dictionary, stat:String, value:Variant):
	if(!stats.has(stat)):
		stats[stat] = value
	else:
		stats[stat] += value


# total stats from weather array
static func get_total_w(weather:Array) -> Dictionary:
	var total = {}
	for i in weather:
		var stats = get_weather_stats(i)
		#print("aaa",stats)
		for stat in stats:
			#print("a",stat)
			if(!total.has(stat)):
				total[stat] = stats[stat]
			else:
				total[stat] += stats[stat]
	return total

# return stat mods for weather type
static func get_weather_stats(weather:int) -> Dictionary:
	if(weather < weather_type.size()):
		return effect_list[category.WEATHER][weather]
	else:
		return {}


# adds effect based on weather
static func update_weather_eff(effects:Dictionary):
	if(Global.api_success):
		var weather = Global.current_weather()
		if weather.has("type"):
			for type in weather.type:
				add_effect(effects, category.WEATHER, type)

# remove weather and set stat mods
static func clear_weather(effects:Dictionary):
	effects[category.WEATHER] = {}
	effects.total_mod = get_total_stat(effects)

# update weather effect and set stat mods
static func set_stat_mod(effects:Dictionary):
	update_weather_eff(effects)
	
	effects.total_mod = get_total_stat(effects)
	print_debug("total", effects.total_mod)
	

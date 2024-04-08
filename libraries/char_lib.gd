extends Resource

enum stats_type {ATK, SPEED, MAX_HP, DMG_TAKEN, ATK_SIZE}

enum category {WEATHER,UPGRADE,TOTAL}
enum weather_type {CLEAR, CLOUDS, RAIN, SNOW, STORM, WIND}

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

const upgrade_format = {
	#"id"=0,
	"node"=null, #if uses node
	"stats"={}
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

# add stat upgrade
static func add_stat_upgrade(effects:Dictionary, stat:String, n:float) -> void:
	add_upgrade_dict(effects, {stat:n})

# add upgrade from stat dict
static func add_upgrade_dict(effects:Dictionary, stats:Dictionary, node:Node=null) -> void:
	var upgrade = upgrade_format.duplicate()
	upgrade["stats"] = stats
	
	if node != null: upgrade["node"] = node
	
	# add upgrade, add stats to total
	effects[category.UPGRADE]["list"].append(upgrade)
	
	for stat in stats.keys():
		effects[category.UPGRADE]["total"][stat] += stats[stat]


# return total stat mod from dictionary
static func get_total(effects:Dictionary) -> Dictionary:
	var total = {}
	
	# loop through weather and upgrade categories
	for weather in effects[0]:
		#print_debug(effect)
		for stat in effects[0][weather]:
			if(!total.has(stat)):
				total[stat] = effects[0][weather][stat]
			else:
				total[stat] += effects[0][weather][stat]
	
	var upgrade_total = effects[category.UPGRADE]["total"]
	for stat in upgrade_total:
		if(!total.has(stat)):
			total[stat] = upgrade_total[stat]
		else:
			total[stat] += upgrade_total[stat]
	
	return total

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
	effects.total_mod = get_total(effects)

# update weather effect and set stat mods
static func set_stat_mod(effects:Dictionary):
	update_weather_eff(effects)
	effects.total_mod = get_total(effects)
	

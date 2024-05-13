extends Resource

enum category {WEATHER,STAT_UPGRADE,ABILITY_UPGRADE}

enum weather_type {CLEAR, CLOUDS, RAIN, SNOW, STORM, WIND}
enum stats_type {ATK, SPEED, MAX_HP, ATK_SIZE, DMG_TAKEN}
enum ability_type {NORMAL, SWORD, TORNADO, PARASOL, FIRE, ICE}

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
	category.STAT_UPGRADE : {
		stats_type.ATK: {
			"atk": 0.05
		},
		stats_type.SPEED: {
			"speed": 0.05
		},
		stats_type.MAX_HP: {
			"max_hp": 0.05
		},
		stats_type.ATK_SIZE: {
			"atk_size": 0.05
		},
		stats_type.DMG_TAKEN: {
			"dmg_taken": 0.05
		}
	},
	category.ABILITY_UPGRADE : {
		ability_type.NORMAL:{
			script = null
		},
		ability_type.SWORD:{},
		ability_type.TORNADO:{},
	}
}

static func get_effect(eff_category:int, eff_type:int, n:int=1, node:Node=null) -> Dictionary:
	var new_type = Vector2(eff_category, eff_type)
	var has_stats = false
	var new_stats = {}
	
	if eff_type in effect_list[eff_category]:
		has_stats = true
		new_stats = effect_list[eff_category][eff_type]

	return {type=new_type, has_stats=has_stats, stats=new_stats, count=n, node=node}

static func get_weather(type:int):
	return get_effect(category.WEATHER, type)

static func get_upgrade(stat:String):
	var stat_i = stats_type.get(stat.to_upper())

	return get_effect(category.STAT_UPGRADE, stat_i)

static func get_ability(ability_ : int):
	return get_effect(category.ABILITY_UPGRADE, ability_)


static func combine_stat_dict(dict1:Dictionary, dict2:Dictionary) -> Dictionary:
	var combined = dict1.duplicate()
	
	for stat in dict2:
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
		var stats = {}
		
		# no change if not in list
		if(i < weather_type.size()):
			stats = effect_list[category.WEATHER][i]
		
		for stat in stats:
			if(!total.has(stat)):
				total[stat] = stats[stat]
			else:
				total[stat] += stats[stat]
	return total

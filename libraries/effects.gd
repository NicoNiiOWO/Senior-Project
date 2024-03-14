extends Resource

enum weather_type {CLEAR, CLOUDS, RAIN, SNOW, STORM, WIND}
const weather_effects : Dictionary = { # stats
	weather_type.CLEAR : {
		"atk": 0.2,
	},
	weather_type.CLOUDS : {},
	weather_type.RAIN : {
		"atk": -0.1,
		"speed": -0.2,
	},
	weather_type.SNOW : {
		"speed": -0.2,
		"dmg_taken": -0.2
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
}

# return total stat mod from array of weather effect
static func get_total(weather : Array) -> Dictionary:
	var total = {}
	for i in weather:
		for stat in weather_effects[i].keys():
			if(!total.has(stat)):
				total[stat] = weather_effects[i][stat]
			else:
				total[stat] += weather_effects[i][stat]
	print(total)
	return total

# input character effects and stats
# modify stats for each effect
static func update_effects(effects, stats):
	effects.weather = []
	effects.total = {}
	#print_debug(Global.weather_data)
	if(Global.api_success && Global.weather_data.has("type")):
		# add effects based on weather type
		for type in Global.weather_data.type:
			effects.weather.append(weather_effects[type])
		
		# calculate total modifier
		var total = {}
		if(effects.weather.size() > 0):
			for effect in effects.weather:
				for key in effect.keys():
					if(total.has(key)): total[key] += (effect[key])
					else: total[key] = effect[key]
		
		effects.total=total
		
		# update stats
		for stat in total.keys():
			stats[stat] *= 1+total[stat]
		
		#print_debug(effects)

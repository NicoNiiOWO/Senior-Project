extends Resource

const weather_effects : Dictionary = { # stats
	clear = {
		"atk": 0.2,
	},
	clouds = {},
	rain = {
		"atk": -0.1,
		"speed": -0.2,
	},
	snow = {
		"speed": -0.2,
		"dmg_taken": -0.2
	},
	storm = {
		"max_hp": -0.1,
		"atk": 0.3,
		"speed": 0.1
	},
	wind = {
		"atk": -0.2,
		"speed": 0.3
	}
}

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

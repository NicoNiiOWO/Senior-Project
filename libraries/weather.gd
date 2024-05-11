extends Node

signal weather_updated() # if weather changed

enum weather_type {CLEAR, CLOUDS, RAIN, SNOW, STORM, WIND}

const eff_lib = preload("res://libraries/effect_lib.gd")

var api_success : bool = false
var api_response_code
var api_response : Dictionary = {
	list = [],
}
var api_ready = false # if variables are set up
var forecast : Array = [{}]

var count : int = 0 # max
var index : int = 0 : set = update # current index in list
var prev_index : int = -1 # most recent index used for forecast

const icon_path_format : String = "res://assets/Icons/Weather/%s@2x.png"
var loaded_icons = {} # list of loaded icon textures

var weather_interval # time between game weather change in seconds
var api_interval # time between api response entries

var timezone = Time.get_time_zone_from_system()

var weather_stat_mod : Dictionary = { # changes to stats from current weather
	mods = {},
	text = ""
} 

# clear api variables
func clear():
	Config.clear_api()
	api_success = false
	api_response_code = null
	api_response = {}
	index = -1
	forecast = [{}]
	api_ready = false

func restart():
	index = 0
	prev_index = -1

# timezone abbreviation
func _init():
	var abbrev = ""
	for word in timezone.name.split(" "):
		abbrev += word[0]
	timezone.abbrev = abbrev
	#print_debug(timezone)

func current_weather() -> Dictionary:
	if index != -1: 
		return forecast[index]
	else: return {}

func get_weather(i:int) -> Dictionary:
	return forecast[i]


func handle_response(response_code, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	api_response_code = response_code
	api_response = json.get_data()
	
	# if successful
	if(response_code == 200):
		api_success = true
		# datetime difference between responses
		api_interval = (api_response.list[1].dt - api_response.list[0].dt)
	
	# set forecast
	set_forecast()
	update()

# get weather as text, default to current
const text_format : String = "{Description}\n{Temp_C}°C/{Temp_F}°F\nWind {Speed} m/s\nGust {Gust} m/s"
#const wind_f = "Windy ({Speed} m/s)\n"
func get_text(i:int=index) -> String:
	var weather = forecast[i]
	
	var text = text_format.format({
		Temp_C = "%0.2f" % weather.temp_c,
		Temp_F = "%0.2f" % weather.temp_f,
		Weather = weather.main, 
		Description = weather.description,
		Speed = weather.wind.speed,
		Gust = weather.wind.gust,
	})
	if(weather.type.has(weather_type.WIND)):
		#text += wind_f.format({
			#Speed = weather.wind.speed
		#})
		text += "\nWindy"
	
	return text + "\n"

func load_icon(code:String) -> Texture2D:
	if code not in loaded_icons.keys():
		var icon_path = icon_path_format % code
		
		loaded_icons[code] = load(icon_path)
	return loaded_icons[code]

func get_icon() -> Texture2D:
	return load_icon(current_weather().icon)

# make forecast
func set_forecast() -> bool: 
	if(api_success):
		var prev_type = []
		
		count = api_response.cnt
		
		for i in range(count):
			if i == 0: forecast[0] = process_weather(0)
			else: forecast.append(process_weather(i))
			
			# check if weather type changed
			forecast[i].typeChanged = (prev_type != forecast[i].type)
			prev_type = forecast[i].type
		
		api_ready = true
	
	Global.timer.set_text()
	weather_updated.emit()
	#print_debug(api_success, forecast)
	return api_ready

# simplify response at index
func process_weather(i:int) -> Dictionary: 
	var entry = api_response.list[i]
	var weather_data = entry.weather[0].duplicate()
	weather_data.description = weather_data.description.capitalize()
	weather_data.wind = entry.wind.duplicate()

	# Calculate temperature
	weather_data.temp_c = snapped(entry.main.temp-273.15, 0.01)
	weather_data.temp_f = snapped(weather_data.temp_c * 1.8 + 32, 0.01)
	
	weather_data.dt = entry.dt
	weather_data.local_dt = weather_data.dt + timezone.bias*60
	
	weather_data.wind = {}
	weather_data.wind.speed = entry["wind"]["speed"]
	weather_data.wind.gust = entry["wind"]["gust"]
	
	set_type(weather_data)
	load_icon(weather_data.icon)
	
	return weather_data

# set weather type based on weather code: https://openweathermap.org/weather-conditions
func set_type(weather_data : Dictionary):
	var type = []
	var code = weather_data.id
	var group = int(code/100)
	
	match group:
		2: # Thunderstorm
			type.append(weather_type.STORM)
		3: # Drizzle/Rain
			type.append(weather_type.RAIN)
		5: # Rain
			type.append(weather_type.RAIN)
		6: # Snow
			type.append(weather_type.SNOW)
			if(code == 615 || code == 616):
				type.append(weather_type.RAIN)
		7: # Atmosphere
			type.append(weather_type.CLOUDS)
		8: # Clear/Cloudy
			if(code==800): type.append(weather_type.CLEAR)
			else: type.append(weather_type.CLOUDS)
	
	if(weather_data.wind.speed > 8 || weather_data.wind.gust > 8):
		type.append(weather_type.WIND)
	
	weather_data.type = type

func set_weather_stats():
	weather_stat_mod.mods = eff_lib.get_total_w(current_weather().type)
	weather_stat_mod.text = Stats.get_stats_text(weather_stat_mod.mods, true)

# return true if looped
func increment() -> bool:
	print(index)
	if(index < api_response.cnt-1):
		index += 1
		return true
	else: 
		index = 0
		return false

# call when index changes
func update(i=index):
	if i == -1: return
	index = i
	if(prev_index != index): # call once per weather change
		if index == -1: index = 0
		
		# Load weather icon
		#load_icon(current_weather().icon)
		
		prev_index = index
		
		if current_weather() != {}:
			if(current_weather().typeChanged): 
				set_weather_stats()
				#weather_changed.emit()
			weather_updated.emit()

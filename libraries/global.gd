extends Node

enum char_type {PLAYER, ENEMY} # use to initialize character
var char_type_str : Array = ["Player", "Enemy"]

enum weather_type {CLEAR, CLOUDS, RAIN, SNOW, STORM, WIND}

var game_ongoing : bool = false # if game is started and not over
var game_paused : bool = false

var map_size : int = 5120 # size of map

var level_timer = {
	minutes = 0,
	seconds = 0,
	total_seconds = 0
}

var player_stats = {
	level = 1,
	max_exp = 0,
	exp = 0,
	max_hp = 0,
	hp = 0,
	atk = 0,
	speed = 0
}


# API variables
const location_preset = [
	{
		city = "Brooklyn, New York",
		lat = 40.6526006,
		lon = -73.9497211,
		
	},
	{
		city = "Tampa, Florida",
		lat = 27.9477595,
		lon = -82.45844,
	},
	{
		city = "Los Angeles, California",
		lat = 34.0536909,
		lon = -118.242766,
	},
	{
		city = "Tokyo, JP",
		lat = 35.6828387,
		lon = 139.7594549,
	}
]
var api_settings : Dictionary = {
	latitude=null,
	longitude=null,
	key=null,
	use_key=false,
}
var api_success : bool = false
var api_response_code
var api_response : Dictionary = {
	list = [],
}
var api_ready = false # if variables are set up
var forecast : Array = [{}]
var index : int = 0 # current index in list

var weather_interval # time between game weather change in seconds
var api_interval # time between api response entries

var timezone = Time.get_time_zone_from_system()

# clear api variables
func clear():
	api_settings = {latitude=null,longitude=null,key=null}
	api_success = false
	api_response_code = null
	api_response = {}
	index = -1
	forecast = [{}]
	api_ready = false

# save settings to config
func save_config_dict(settings:Dictionary)-> Error:
	return save_config(settings.latitude, settings.longitude, settings.key, settings.use_key)
	
func save_config(lat, lon, key=null, use_key=null) -> Error:
	var config = ConfigFile.new()
	config.load("res://config.cfg")
	
	# use selected longitude/latitude and key
	config.set_value("API", "latitude", lat)
	config.set_value("API", "longitude", lon)
	config.set_value("API", "key", key)
	
	# if use_key is not provided, set to true if key is set
	if use_key == null: use_key = (key != null)
	config.set_value("API", "use_key", use_key)
	
	api_settings.latitude = lat
	api_settings.longitude = lon
	if key != null: api_settings.key = key
	api_settings.use_key = use_key
	
	return config.save("res://config.cfg")

# timezone abbreviation
func _init():
	var abbrev = ""
	for word in timezone.name.split(" "):
		abbrev += word[0]
	timezone.abbrev = abbrev
	print_debug(timezone)

func current_weather() -> Dictionary:
	if index != -1: 
		return forecast[index]
	else: return {}

func get_weather(i:int) -> Dictionary:
	return forecast[i]

const text_format : String = "{Description}\n{Temp_C}°C/{Temp_F}°F\n"

# get weather as text, default to current
func get_text(i:int=index) -> String:
	var weather = forecast[i]
	
	var text = text_format.format({
		Temp_C = "%0.2f" % weather.temp_c,
		Temp_F = "%0.2f" % weather.temp_f,
		Weather = weather.main, 
		Description = weather.description,
	})
	if(weather.type.has(weather_type.WIND)):
		text += "Windy\n"
	return text

# make forecast
func set_forecast() -> bool: 
	if(api_success):
		var prev_type = []
		
		print_debug(forecast)
		for i in range(api_response.cnt):
			if i == 0: forecast[0] = process_weather(0)
			else: forecast.append(process_weather(i))
			
			# check if weather type changed
			forecast[i].typeChanged = (prev_type != forecast[i].type)
			prev_type = forecast[i].type
		
		api_ready = true
	print_debug(api_success, forecast)
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
	
	set_type(weather_data)
	
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
	
	#print(weather_data)
	if(weather_data["wind"]["speed"] > 8 || weather_data["wind"]["gust"] > 8):
		type.append(weather_type.WIND)
	
	# return true if types changed
	#if(!forecast[index].has("type") || forecast[index].type != type): 
	weather_data.type = type

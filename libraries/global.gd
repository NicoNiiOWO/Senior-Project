extends Node

enum char_type {PLAYER, ENEMY} # use to initialize character
var char_type_str : Array = ["Player", "Enemy"]

#enum weather_type {CLEAR, CLOUDS, RAIN, SNOW, STORM, WIND}

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
var api_settings : Dictionary = {
	latitude=null,
	longitude=null,
	key=null
}
var api_success : bool = false
var api_response_code
var api_response : Dictionary = {
	list = [],
}
var index : int = 0 # current index in list

var weather_data : Dictionary = { } # info used

var weather_interval# time between game weather change in seconds
var api_interval # time between api response entries

var timezone = Time.get_time_zone_from_system()


func _init():
	var acronym = ""
	for word in timezone.name.split(" "):
		acronym += word[0]
	timezone.acronym = acronym
	print_debug(timezone)
	
func setWeatherData(i): # simplify response at index
	#print_debug("EE")
	if(api_success):
		var entry = api_response.list[i]
		#print_debug("AAA",entry)
		weather_data = entry.weather[0].duplicate()
		weather_data.description = weather_data.description.capitalize()
		weather_data.index = i
		weather_data.wind = entry.wind.duplicate()

		# Calculate temperature
		weather_data.temp_c = entry.main.temp-273.15
		weather_data.temp_f = weather_data.temp_c * 1.8 + 32
		
		weather_data.dt = entry.dt
		
		weather_data.local_dt = weather_data.dt + timezone.bias*60
		
		print_debug(weather_data)
		return setType()

# set weather type based on weather code: https://openweathermap.org/weather-conditions
func setType():
	var type = []
	var code = weather_data.id
	var group = int(code/100)
	
	match group:
		2: # Thunderstorm
			type.append("storm")
		3: # Drizzle/Rain
			type.append("rain")
		5: # Rain
			type.append("rain")
		6: # Snow
			type.append("snow")
			if(code == 615 || code == 616):
				type.append("rain")
		7: # Atmosphere
			type.append("clouds")
		8: # Clear/Cloudy
			if(code==800): type.append("clear")
			else: type.append("clouds")
	
	type.append("wind")
	
	# return true if types changed
	if(!weather_data.has("type") || weather_data.type != type): 
		weather_data.type = type
		return true
	return false

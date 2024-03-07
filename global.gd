extends Node

enum char_type {PLAYER, ENEMY} # use to initialize character

enum weather_type {CLEAR, CLOUDS, RAIN, SNOW, STORM, WIND}

var map_size

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
var api_success = false
var api_response_code
var api_response = {
	list = [],
}
var index = 0 # current index in list

var weather_data = { } # info used

var weather_interval # time between game weather change in seconds
var api_interval # time between api response entries

var timezone = Time.get_time_zone_from_system()


func _init():
	var acronym = ""
	for word in timezone.name.split(" "):
		acronym += word[0]
	timezone.acronym = acronym
	print(timezone)
	
func setWeatherData(index): # simplify response at index
	if(api_success):
		var entry = api_response.list[index]
		weather_data = entry.weather[0].duplicate()
		weather_data.description = weather_data.description.capitalize()
		weather_data.index = index
		weather_data.wind = entry.wind.duplicate()

		# Calculate temperature
		weather_data.temp_c = entry.main.temp-273.15
		weather_data.temp_f = weather_data.temp_c * 1.8 + 32
		
		weather_data.dt = entry.dt
		
		weather_data.local_dt = weather_data.dt + timezone.bias*60
		
		setType()
		print(weather_data)

# set weather type based on weather code: https://openweathermap.org/weather-conditions
func setType():
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
	
	if(weather_data.wind.speed > 9): type.append(weather_type.WIND)
	
	weather_data.type = type

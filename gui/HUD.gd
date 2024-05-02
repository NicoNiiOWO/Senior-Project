extends Control

var player : Player = null
@onready var gui = get_parent()

var weather_data : Dictionary # current weather from forecast
var prev_index : int = -1 # most recent index used for forecast

const datetime_f : String = "{year}/{month}/{day} {hour}:{minute}"
const time_f : String = "%02d:%02d"
const clock_format : String = "{Time} {Timezone}"

# Display player stats
func update_stats():
	player = Global.player
	var stats = player.stats
	
	%HP.text = str("HP: ", stats.hp,"/", stats.max_hp)
	%Level.text = str("Level: ", stats.level, " EXP: ", stats.exp, "/", stats.max_exp)
	
	
	var text = Stats.get_stats_text(stats)
	%PlayerStats.text = text
	
	var upgrade_text = ""
	if player.effects.size > 0:
		upgrade_text += "\nUpgrades:\n" + player.effects.get_ability_txt()
		upgrade_text += Stats.get_stats_text(player.effects.total_mod,false,true)
	%PlayerUpgrades.text = upgrade_text

# update weather info
func weather_update():
	var response = Weather.api_response
	#print_debug(Weather.api_success, Weather.api_response_code)
	
	if Weather.api_success: # Response successful
		#print_debug("Index: ",Weather.index,"/", response.cnt-1)
		if(prev_index != Weather.index): # call once per weather change
			if Weather.index == -1:
				Weather.index = 0
			weather_data = Weather.current_weather()
			
			# Load weather icon
			#print_debug(weather_data)
			var icon = gui.load_icon(weather_data.icon)
			%Icon.set_texture(icon)
			
			prev_index = Weather.index
			
			if(weather_data.typeChanged): 
				Weather.set_weather_stats()
				gui.weather_changed.emit()
				
			set_weather_text()
		
	else:
		if(response != null && response.message != null):
			#print_debug(response.message)
			error(str("Error ",Weather.api_response_code, " ", response.message))
	
	show_weather(Weather.api_success)

func show_weather(success:bool):
	if(success):
		%ErrorMessage.hide()
		%Icon.show()
		%Clock.show()
		%WeatherText.show()
	else:
		%ErrorMessage.show()
		%Icon.hide()
		%Clock.hide()
		%WeatherText.hide()
	$Weather.show()

func error(text: String):
	%ErrorMessage.text = text
	show_weather(false)
	

var weather_text = ""
# display weather info and update clock
func set_weather_text():
	# ignore on api response error
	if(!Weather.api_success): return
	
	weather_text = Weather.get_text()
	weather_text += Weather.weather_stat_mod.text
	%WeatherText.text = weather_text
	set_clock()

func set_clock():
	# ignore on api response error
	if(!Weather.api_ready): return
	
	# offset game clock proportionally to weather interval and api interval
	var time_offset = Weather.api_interval/Weather.weather_interval * (Global.level_timer.total_seconds % Weather.weather_interval)
	var text = get_clock_str(weather_data.local_dt + time_offset)
	
	%Clock.text = text

func get_clock_str(unix:int) -> String:
	var time = Time.get_datetime_dict_from_unix_time(unix)
	if(time.minute < 10):
		time.minute = str(0, time.minute)
	
	var text = clock_format.format({
		Time = datetime_f.format(time),
		Timezone = Weather.timezone.abbrev,
	})
	return text

# Call every second, update timer
func _on_game_timer_timeout():
	#time_update.emit()
	var time = Global.level_timer
	#print_debug(time)

	time.total_seconds += 1
	time.seconds += 1
	if(time.seconds >= 60):
		time.seconds -= 60
		time.minutes += 1
	
	# increment weather on interval
	if(Weather.api_success && time.seconds > 0 && time.total_seconds % Weather.weather_interval == 0):
		#print_debug("e")
		
		Weather.increment()
		weather_update()
	
	#print_debug(Weather.weather_data)
	if Weather.api_ready: set_clock()
	
	var index_text = str("\n",Weather.index+1, "/", Weather.api_response.cnt)
	$Timer.text = time_f % [time.minutes, time.seconds] + index_text

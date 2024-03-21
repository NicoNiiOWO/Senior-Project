extends CanvasLayer

signal restart()
signal time_update() # called every second when game timer updates
signal weather_changed()
signal pause()



@export var icon_path_format : String = "res://assets/Icons/%s@2x.png"

var datetime_f : String = "{year}/{month}/{day} {hour}:{minute}"
var time_f : String = "%02d:%02d"
var text_format : String = "{Time} {Timezone}\n{Description}\n{Temp_C}°C/{Temp_F}°F\n"

var prev_index : int = -1 # most recent index used on weather list

var reload_settings : bool = false # reload settings on restart

const effects_lib = preload("res://libraries/effects.gd")
var weather_stat_mod : Dictionary = { # changes to stats from current weather
	mods = {},
	text = ""
} 

func _input(event):
	# pause game when running
	if Global.game_ongoing && event.is_action_pressed("pause"):
		pause.emit(true)
	
	# restart when pressing button
	if $GameOver.visible && event.is_action_pressed("attack"):
		_on_restart_button_pressed()

# start timer
func start():
	var timer = $GameTimer
	timer.wait_time = 1
	Global.level_timer.minutes = 0
	Global.level_timer.seconds = 0
	
	$HUD/Timer.text = "00:00"
	
	timer.start()
	update_stats()

# Display player stats
func update_stats():
	var stats = Global.player_stats
	
	%HP.text = str("HP: ", stats.hp,"/", stats.max_hp)
	%Level.text = str("Level: ", stats.level, " EXP: ", stats.exp, "/", stats.max_exp)

# update weather info
func weather_update():
	var response = Global.api_response
	#print_debug(Global.api_success, Global.api_response_code)
	
	if Global.api_success: # Response successful
		#print_debug("Index: ",Global.index,"/", response.cnt-1)
		if(prev_index != Global.index): # call once per weather change
			var type_changed = Global.setWeatherData(Global.index)

			# Load weather icon
			var icon_code = Global.weather_data.icon
			var icon_path = icon_path_format % icon_code
			
			var icon = load(icon_path)
			%Icon.set_texture(icon)
			
			
			prev_index = Global.index
			
			if(type_changed): 
				get_weather_stats()
				weather_changed.emit()
				
			set_weather_text()
		
	else:
		if(response != null && response.message != null):
			#print_debug(response.message)
			%ErrorMessage.text = str(Global.api_response_code, " ", response.message)
			%Icon.visible = false
	
	$HUD/Weather.visible = true

# make text from current weather stat modifier
func get_weather_stats():
	weather_stat_mod.mods = effects_lib.get_total_w(Global.weather_data.type)
	weather_stat_mod.text = ""
	
	#print("e",weather_stat_mod.mods)
	
	if(weather_stat_mod.mods.size() > 0):
		var text = ""
		for stat in weather_stat_mod.mods.keys():
			var mod = weather_stat_mod.mods[stat]*100
			if(mod != 0):
				text += stat.capitalize() + " "

				if mod > 0: text += "+"
				
				text += "%d%%\n" % mod

		weather_stat_mod.text = text.left(text.length()-1) # remove last newline
		#print(text)

# display weather info and update clock
func set_weather_text():
	# ignore on api response error
	if(!Global.api_success): return
	
	# offset game clock proportionally to weather interval and api interval
	var time_offset = Global.api_interval/Global.weather_interval * (Global.level_timer.total_seconds % Global.weather_interval)
	#print(time_offset/60," ", Global.api_interval/Global.weather_interval/60," ", (Global.level_timer.total_seconds % Global.weather_interval))
	
	# Convert UTC to local time
	#print_debug(Global.weather_data)
	var time = Time.get_datetime_dict_from_unix_time(Global.weather_data.local_dt + time_offset)
	if(time.minute < 10):
		time.minute = str(0, time.minute)

	var text = text_format.format({
		Temp_C = "%0.2f" % Global.weather_data.temp_c,
		Temp_F = "%0.2f" % Global.weather_data.temp_f,
		Weather = Global.weather_data.main, 
		Description = Global.weather_data.description,
		Time = datetime_f.format(time), 
		Timezone = Global.timezone.acronym,
	})
	if(Global.weather_data.type.has(Global.weather_type.WIND)):
		text += "Windy\n"
	text += weather_stat_mod.text
	%WeatherText.text = text

func game_over():
	$GameOver.set_visible(true)
	$GameTimer.stop()

# call restart 
# reset settings and hide weather ui if changed
func _on_restart_button_pressed():
	$GameOver.set_visible(false)
	restart.emit(reload_settings)
	
	if(reload_settings): $HUD/Weather.hide()
	reload_settings = false


# Call every second, update timer
func _on_game_timer_timeout():
	time_update.emit()
	var time = Global.level_timer
	#print_debug(time)

	time.total_seconds += 1
	time.seconds += 1
	if(time.seconds >= 60):
		time.seconds -= 60
		time.minutes += 1
	
	# increment weather on interval
	if(Global.api_success && time.seconds > 0 && time.total_seconds % Global.weather_interval == 0):
		#print_debug("e")
		
		# loop weather at end of array
		if(Global.index < Global.api_response.cnt):
			Global.index += 1
		else: Global.index = 0
		weather_update()
	
	#print_debug(Global.weather_data)
	if Global.api_ready: set_weather_text()
	$HUD/Timer.text = time_f % [time.minutes, time.seconds]

func _on_settings_changed():
	reload_settings = true

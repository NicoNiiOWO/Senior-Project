extends CanvasLayer

signal restart()
signal time_update() # called every second when game timer updates
signal weather_changed()
signal pause()

@export var icon_path_format : String = "res://assets/Icons/%s@2x.png"

var datetime_f : String = "{year}/{month}/{day} {hour}:{minute}"
var time_f : String = "%02d:%02d"
var text_format : String = "{Time} {Timezone}\n{Description}\n{Temp_C}°C/{Temp_F}°F"

var prev_index : int = -1 # most recent index used on weather list

@onready var parent = get_tree()
func _ready():
	print(parent.root)

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
			#print_debug("QQQ", type_changed)
			# Load weather icon
			var icon_code = Global.weather_data.icon
			var icon_path = icon_path_format % icon_code
			
			var icon = load(icon_path)
			%Icon.set_texture(icon)
			
			set_weather_text()
			prev_index = Global.index
			
			if(type_changed): weather_changed.emit()
		
	else:
		if(response != null && response.message != null):
			#print_debug(response.message)
			%ErrorMessage.text = str(Global.api_response_code, " ", response.message)
			%Icon.visible = false
	
	$HUD/Weather.visible = true

# display weather info and update clock
func set_weather_text():
	# ignore on api response error
	if(!Global.api_success):
		return
	
	# offset game clock proportionally to weather interval and api interval
	var time_offset = Global.api_interval/Global.weather_interval * (Global.level_timer.total_seconds % Global.weather_interval)
	
	# Convert UTC to local time
	#print_debug()
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
		Timezone = Global.timezone.acronym
	})
	if(Global.weather_data.type.has("wind")):
		text += "\nWindy"

	%WeatherText.text = text

func game_over():
	$GameOver.set_visible(true)
	#%RestartButton.disabled = false
	$GameTimer.stop()

func _on_restart_button_pressed():
	$GameOver.set_visible(false)
	#%RestartButton.disabled = true
	restart.emit()


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
	set_weather_text()
	$HUD/Timer.text = time_f % [time.minutes, time.seconds]


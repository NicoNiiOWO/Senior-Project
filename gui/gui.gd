extends CanvasLayer

signal restart()

@export var icon_path_format = "res://assets/Icons/%s@2x.png"

var datetime_f = "{year}/{month}/{day} {hour}:{minute}"
var time_f = "%02d:%02d"
var text_format = "{Temp_C}°C/{Temp_F}°F\n{Weather}\n{Time}\n{Timezone}"

var prev_index # most recent index used

var weather_data = { # data displayed in hud
	temp_c = 0,
	temp_f = 0,
	weather_str = "", 
	timezone = Global.timezone.name
}

func start():
	var timer = $GameTimer
	timer.wait_time = 1
	Global.level_timer.minutes = 0
	Global.level_timer.seconds = 0
	
	$HUD/Timer.text = "00:00"
	
	timer.start()
	update_stats()

func update_stats():
	var stats = Global.player_stats
	
	%HP.text = str("HP: ", stats.hp,"/", stats.max_hp)
	%Level.text = str("Level: ", stats.level, " EXP: ", stats.exp, "/", stats.max_exp)

func weather_update():
	var response = Global.api_response
	print("Index: ",Global.index,"/", response.cnt-1)
	
	if Global.api_response_code == 200: # Response successful
		
		if(prev_index != Global.index): # call once per weather change
			Global.weather = response.list[Global.index]

			# Set weather data
			weather_data.weather_str = Global.weather.weather[0].main
			# Calculate temperature
			weather_data.temp_c = Global.weather.main.temp-273.15
			weather_data.temp_f = weather_data.temp_c * 1.8 + 32

			# Load weather icon
			var icon_code = Global.weather.weather[0].icon
			var icon_path = icon_path_format % icon_code
			
			var icon = Image.load_from_file(icon_path)
			var texture = ImageTexture.create_from_image(icon)
			%Icon.set_texture(texture)
			
			set_weather_text()
			prev_index = Global.index
		
	else:
		if(response.message != null):
			print(response.message)
			%ErrorMessage.text = str(Global.api_response_code, " ", response.message)
			%Icon.visible = false
	
	$HUD/Weather.visible = true

func set_weather_text():
	# offset game clock proportionally to weather interval and api interval
	var offset = Global.api_interval/Global.weather_interval * (Global.level_timer.total_seconds % Global.weather_interval)
	
	# Convert UTC to local time
	var local_unix = Global.weather.dt + Global.timezone.bias*60
	var time = Time.get_datetime_dict_from_unix_time(local_unix + offset)
	if(time.minute < 10):
		time.minute = str(0, time.minute)

	var text = text_format.format({
		Temp_C = "%0.2f" % weather_data.temp_c,
		Temp_F = "%0.2f" % weather_data.temp_f,
		Weather = weather_data.weather_str, 
		Time = datetime_f.format(time), 
		Timezone = Global.timezone.name
	})
	%WeatherText.text = text

func game_over():
	$GameOver.set_visible(true)
	%RestartButton.disabled = false
	$GameTimer.stop()


func _on_restart_button_pressed():
	$GameOver.set_visible(false)
	%RestartButton.disabled = true
	restart.emit()


# Call every second
func _on_game_timer_timeout():
	var time = Global.level_timer
	print(time)
	time.total_seconds += 1
	time.seconds += 1
	if(time.seconds >= 60):
		time.seconds -= 60
		time.minutes += 1
	
	# increment weather on interval
	if(time.seconds > 0 && time.total_seconds % Global.weather_interval == 0):
		print("e")
		
		# loop if reached end
		if(Global.index < Global.api_response.cnt):
			Global.index += 1
		else: Global.index = 0
		weather_update()

	set_weather_text()
	$HUD/Timer.text = time_f % [time.minutes, time.seconds]

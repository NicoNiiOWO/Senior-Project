extends CanvasLayer

signal restart()

@export var icon_path_format = "res://assets/Icons/%s@2x.png"

func update_stats():
	var HP = $HUD/HP
	var stats = Global.player_stats
	
	HP.text = str("HP: ", stats.hp,"/", stats.max_hp)
	($HUD/Level).text = str("Level: ", stats.level, " EXP: ", stats.exp, "/", stats.max_exp)

func weather_update():
	var response = Global.api_response
	
	var text = ""
	if Global.api_response_code == 200: # Response successful
		Global.weather = response.list[Global.index]
		var weather = Global.weather.duplicate()
	
		# Display weather
		print("Response Count: ",response.cnt)
		print(response.list[0])
		weather.weather = Global.weather.weather[0].main

		# Convert UTC to local time in unix
		var local_time = Global.weather.dt + Time.get_time_zone_from_system().bias*60
		#print(Time.get_datetime_string_from_unix_time(local_time))
		#print(Time.get_datetime_dict_from_unix_time(local_time))
		var local_time_str = Time.get_datetime_string_from_unix_time(local_time).replace("T", "\n")
		
		
		text = str(weather.weather, "\n", local_time_str)
		print()
		print(weather)
		# Load weather icon
		var icon_code = Global.weather.weather[0].icon
		var icon_path = icon_path_format % icon_code
		
		var icon = Image.load_from_file(icon_path)
		var texture = ImageTexture.create_from_image(icon)
		(%Icon).set_texture(texture)
		
		(%WeatherText).text = text
		
	else:
		if(response.message != null):
			print(response.message)
			(%ErrorMessage).text = str(Global.api_response_code, " ", response.message)
			(%Icon).visible = false
	
	($HUD/Weather).visible = true

func game_over():
	$GameOver.set_visible(true)
	$GameOver/RestartButton.disabled = false


func _on_restart_button_pressed():
	$GameOver.set_visible(false)
	$GameOver/RestartButton.disabled = true
	restart.emit()

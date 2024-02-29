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
	var weather = Global.current_weather
	
	var text = ""
	if Global.api_response_code == 200: # Response successful
		
		# Display weather
		print("Response Count: ",response.cnt)
		print(response.list[0])
		weather.weather = response.list[0].weather[0].main
		weather.datetime = response.list[0].dt_txt.replace(" ", "\n")
		
		text = str(weather.weather, "\n", weather.datetime, " UTC")
		print(Global.current_weather.weather)
		
		# Load weather icon
		var icon_code = response.list[0].weather[0].icon
		var icon_path = icon_path_format % icon_code
		
		var icon = Image.load_from_file(icon_path)
		var texture = ImageTexture.create_from_image(icon)
		($HUD/Weather/Icon).set_texture(texture)
		
		(%WeatherText).text = text
		
	else:
		if(response.message != null):
			print(response.message)
			(%ErrorMessage).text = str(Global.api_response_code, " ", response.message)
	
	($HUD/Weather).visible = true

func game_over():
	$GameOver.set_visible(true)
	$GameOver/RestartButton.disabled = false


func _on_restart_button_pressed():
	$GameOver.set_visible(false)
	$GameOver/RestartButton.disabled = true
	restart.emit()

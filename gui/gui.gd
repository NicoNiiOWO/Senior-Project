extends CanvasLayer

signal restart()

func update_hud():
	var HP = $HUD/HP
	var stats = Global.player_stats
	
	HP.text = str("HP: ", stats.hp,"/", stats.max_hp)
	($HUD/Level).text = str("Level: ", stats.level, " EXP: ", stats.exp, "/", stats.max_exp)
	

func weather_update():
	var weather = $HUD/Weather
	var response = Global.api_response
	
	var text = ""
	if Global.api_response_code == 200: # Response successful
		print("Response Count: ",response.cnt)
		print(response.list[0])
		text = str(Global.api_response.list[0])
	else:
		print(response.message)
		text = str(Global.api_response_code, " ", response.message)
	
	weather.text = text

func game_over():
	$GameOver.set_visible(true)
	$GameOver/RestartButton.disabled = false


func _on_restart_button_pressed():
	$GameOver.set_visible(false)
	$GameOver/RestartButton.disabled = true
	restart.emit()

class_name GUI
extends CanvasLayer

signal restart()
signal time_update() # called every second when game timer updates
signal weather_changed()
signal pause()
signal popup(e)

var reload_settings : bool = false # reload settings on restart

@onready var main = get_node("/root/Main")
var player : Player = null

func set_player(p:Player):
	player=p



func _input(event):
	# pause game when running
	if Global.game_ongoing && event.is_action_pressed("pause"):
		if not $UpgradePopup.popup_active:
			pause.emit(false)
	
	# restart when pressing button
	if $GameOver.visible && event.is_action_pressed("attack"):
		_on_restart_button_pressed()

# start timer
func _on_main_game_start():
	$StartMenu.hide()
	
	var timer = $GameTimer
	timer.wait_time = 1
	Global.level_timer.minutes = 0
	Global.level_timer.seconds = 0
	
	$HUD/Timer.text = "00:00"
	
	timer.start()
	$HUD.update_stats()

# Display player stats
func update_stats():
	$HUD.update_stats()

func _on_main_api_request_complete():
	if Weather.api_success:
		make_forecast()
	$HUD.weather_update()

#func show_weather(success:bool):
	#$HUD.show_weather(success)

#func error(text: String):
	#$HUD.error(text)
#
## update weather info
#func weather_update():
	#$HUD.weather_update()

# make text from current weather stat modifier

func game_over():
	$GameOver.set_visible(true)
	$GameTimer.stop()
	%GORestartButton.grab_focus()


func _on_start_button_pressed():
	main.start(reload_settings)
	reload_settings = false

# call restart 
# reset settings and hide weather ui if changed
func _on_restart_button_pressed():
	$GameOver.set_visible(false)
	#$PauseMenu.unpause()
	restart.emit(reload_settings)
	
	if(reload_settings): $HUD/Weather.hide()
	reload_settings = false


# Call every second, update timer
func _on_game_timer_timeout():
	time_update.emit()
	$HUD._on_game_timer_timeout()

func weather_increment():
	Weather.increment()
	$HUD.weather_update()
	
	
# When settings change, reload settings on next restart
func _on_settings_changed():
	reload_settings = true


# make forecast ui for pause screen
func make_forecast():
	if Weather.api_ready:
		for i in range(len(Weather.forecast)):
			var entry = %ForecastEntry.duplicate()
			var weather = Weather.get_weather(i)
			
			var icon = Weather.load_icon(weather.icon)
			entry.get_child(0).set_texture(icon) # icon
			
			entry.get_child(1).get_child(0).text = $HUD.get_clock_str(weather.local_dt) # time
			entry.get_child(1).get_child(1).text = Weather.get_text(i) # text
			
			entry.show()
			
			
			var separator = HSeparator.new()
			separator.custom_minimum_size.x = 200
			%ForecastList.add_child(separator)
			%ForecastList.add_child(entry)
		%Forecast.show()
	

func clear_forecast():
	for n in %ForecastList.get_children():
		%ForecastList.remove_child(n)
		n.queue_free()

func upgrade_popup(a:Array):
	popup.emit(a)

func _on_pause_menu_unpaused():
	pass # Replace with function body.

func _on_github_button_pressed():
	OS.shell_open("https://github.com/NicoNiiOWO/Senior-Project/")

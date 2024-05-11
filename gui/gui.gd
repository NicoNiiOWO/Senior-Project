class_name GUI
extends CanvasLayer

signal restart()
signal pause()
signal popup(e)

var reload_settings : bool = false # reload settings on restart

@onready var main = get_node("/root/Main")
@onready var timer = Global.timer
var player : Player = null

func set_player(p:Player):
	player=p

func _ready():
	Weather.weather_updated.connect(weather_update)

func _input(event):
	# pause game when running
	if Global.game_ongoing && event.is_action_pressed("pause"):
		if not $UpgradePopup.popup_active:
			pause.emit(false)
	
	# restart when pressing button
	if $GameOver.visible && event.is_action_pressed("attack"):
		_on_restart_button_pressed()

# title screen start button
func _on_start_button_pressed():
	main.start(reload_settings)
	reload_settings = false

# Display player stats
func update_stats():
	$HUD.update_stats()

func _on_main_api_request_complete():
	if Weather.api_success:
		make_forecast()

func open_title():
	main.stop()
	$PauseMenu.unpause()
	$StartMenu.show()
	%StartButton.grab_focus()

func game_over(win=false):
	%GameOverText.visible = !win
	%WinText.visible = win
	
	$GameOver.set_visible(true)
	%GORestartButton.grab_focus()

# call restart 
# reset settings and hide weather ui if changed
func _on_restart_button_pressed():
	$GameOver.set_visible(false)
	$PauseMenu.unpause()
	restart.emit(reload_settings)
	
	if(reload_settings): $HUD/Weather.hide()
	reload_settings = false

func weather_update():
	# scroll to entry
	var scrollbar = %ForecastScroll.get_v_scroll_bar() as ScrollBar
	
	var step = scrollbar.max_value / Weather.count
	scrollbar.value = step * Weather.index
	
# When settings change, reload settings on next restart
func _on_settings_changed():
	reload_settings = true


# make forecast ui for pause screen
func make_forecast():
	if Weather.api_ready:
		for i in range(len(Weather.forecast)):
			var entry = %ForecastEntry.duplicate()
			var weather = Weather.get_weather(i)
			
			%CityLabel.text = Weather.get_city()
			
			var icon = Weather.load_icon(weather.icon)
			entry.get_child(0).set_texture(icon) # icon
			
			entry.get_child(1).get_child(0).text = timer.get_clock_str(weather.local_dt) # time
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

func _on_github_button_pressed():
	OS.shell_open("https://github.com/NicoNiiOWO/Senior-Project/")

func _on_settings_closed():
	if $StartMenu.visible:
		%StartButton.grab_focus()

class_name GUI
extends CanvasLayer

signal restart()
signal time_update() # called every second when game timer updates
signal weather_changed()
signal pause()
signal popup(e)

const icon_path_format : String = "res://assets/Icons/Weather/%s@2x.png"
const datetime_f : String = "{year}/{month}/{day} {hour}:{minute}"
const time_f : String = "%02d:%02d"
const clock_format : String = "{Time} {Timezone}"

var weather_data : Dictionary # current weather from forecast
var prev_index : int = -1 # most recent index used for forecast

var loaded_icons = {} # list of loaded icon textures

var reload_settings : bool = false # reload settings on restart

var player : Player = null

func set_player(p:Player):
	player=p

const char_lib = preload("res://libraries/char_lib.gd")
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
func _on_main_game_start():
	$StartMenu.hide()
	
	var timer = $GameTimer
	timer.wait_time = 1
	Global.level_timer.minutes = 0
	Global.level_timer.seconds = 0
	
	$HUD/Timer.text = "00:00"
	
	timer.start()
	update_stats()

# Display player stats
func update_stats():
	var stats = player.stats
	
	%HP.text = str("HP: ", stats.hp,"/", stats.max_hp)
	%Level.text = str("Level: ", stats.level, " EXP: ", stats.exp, "/", stats.max_exp)
	
	var i = player.effects[1]["list"].size()
	var text = get_stats_text(stats)
	if i != 0:
		text += "\nUpgrades:"+ get_stats_text(player.effects[1]["total"],false,true)
	%PlayerStats.text = text

func _on_main_api_request_complete():
	if Global.api_success:
		make_forecast()
	weather_update()

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
	$HUD/Weather.show()

func error(text: String):
	%ErrorMessage.text = text
	show_weather(false)

# update weather info
func weather_update():
	var response = Global.api_response
	#print_debug(Global.api_success, Global.api_response_code)
	
	if Global.api_success: # Response successful
		#print_debug("Index: ",Global.index,"/", response.cnt-1)
		if(prev_index != Global.index): # call once per weather change
			if Global.index == -1:
				Global.index = 0
			weather_data = Global.current_weather()
			
			# Load weather icon
			print_debug(weather_data)
			var icon = load_icon(weather_data.icon)
			%Icon.set_texture(icon)
			
			prev_index = Global.index
			
			if(weather_data.typeChanged): 
				get_weather_stats()
				weather_changed.emit()
				
			set_weather_text()
		
	else:
		if(response != null && response.message != null):
			#print_debug(response.message)
			error(str("Error ",Global.api_response_code, " ", response.message))
	
	show_weather(Global.api_success)

const txt_percent = "%d%%\n"
const txt_decimal = "%d\n"
const txt_float = "%0.2f\n"
func get_stats_text(stats:Dictionary, weather:bool=false, upgrade=false) -> String:
	if(stats.size() > 0):
		var text = ""
		if !weather: text = "\n"
		#print_debug(stats)
		for stat in stats.keys():
			var mod = stats[stat]
			
			if(mod != 0):
				if(weather): 
					text += stat.capitalize()
					text += " "
					if mod > 0: text += "+"
					mod*=100
					text += txt_percent % mod
				else:
					if stat not in ["level","hp","max_exp","exp"]:
						text += stat.capitalize() + ": "
						
						var format = ""
						
						if upgrade: text += "x" + txt_float % (mod+1)
						else:
							match stat:
								"speed": format = txt_decimal
								_: format = txt_float
							text += format % mod
						#else:							text += ": %d\n" % mod
			#else: text+=stat+"\n"

		#return text.left(text.length()-1) # remove last newline
		return text
	return ""

# make text from current weather stat modifier
func get_weather_stats():
	weather_stat_mod.mods = char_lib.get_total_w(Global.current_weather().type)
	weather_stat_mod.text = get_stats_text(weather_stat_mod.mods, true)

var weather_text = ""
# display weather info and update clock
func set_weather_text():
	# ignore on api response error
	if(!Global.api_success): return
	
	weather_text = Global.get_text()
	weather_text += weather_stat_mod.text
	%WeatherText.text = weather_text
	set_clock()

func set_clock():
	# ignore on api response error
	if(!Global.api_ready): return
	
	# offset game clock proportionally to weather interval and api interval
	var time_offset = Global.api_interval/Global.weather_interval * (Global.level_timer.total_seconds % Global.weather_interval)
	var text = get_clock_str(weather_data.local_dt + time_offset)
	%Clock.text = text

func get_clock_str(unix:int) -> String:
	var time = Time.get_datetime_dict_from_unix_time(unix)
	if(time.minute < 10):
		time.minute = str(0, time.minute)
	
	var text = clock_format.format({
		Time = datetime_f.format(time),
		Timezone = Global.timezone.abbrev,
	})
	return text


func game_over():
	$GameOver.set_visible(true)
	$GameTimer.stop()
	%GORestartButton.grab_focus()


func _on_start_button_pressed():
	restart.emit(reload_settings)
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
	if Global.api_ready: set_clock()
	$HUD/Timer.text = time_f % [time.minutes, time.seconds]

# When settings change, reload settings on next restart
func _on_settings_changed():
	reload_settings = true


func load_icon(code:String) -> Texture2D:
	if code not in loaded_icons.keys():
		var icon_path = icon_path_format % code
		
		loaded_icons[code] = load(icon_path)
	return loaded_icons[code]

# make forecast ui for pause screen
func make_forecast():
	if Global.api_ready:
		for i in range(len(Global.forecast)):
			var entry = %ForecastEntry.duplicate()
			var weather = Global.get_weather(i)
			
			var icon = load_icon(weather.icon)
			entry.get_child(0).set_texture(icon) # icon
			
			entry.get_child(1).get_child(0).text = get_clock_str(weather.local_dt) # time
			entry.get_child(1).get_child(1).text = Global.get_text(i) # text
			
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

func show_popup(a):
	print_debug("qodpklsm")
	popup.emit(a)


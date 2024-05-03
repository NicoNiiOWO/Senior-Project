extends Control

var player : Player = null
@onready var gui = get_parent()
@onready var timer = Global.timer

func _ready():
	Weather.weather_updated.connect(weather_update)
	Weather.weather_changed.connect(weather_change)
	Global.timer.game_timeout.connect(_on_game_timer_timeout)

func start():
	$TimerLabel.text = "00:00"
	update_stats()
	
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
	await timer.game_timeout
	
	var response = Weather.api_response
	
	if(response != null && response.message != null):
		error(str("Error ",Weather.api_response_code, " ", response.message))
	
	show_weather(Weather.api_success)

func weather_change():
	%Icon.set_texture(Weather.get_icon())
	set_weather_text()

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
	
	#set_timer_text()
	weather_text = Weather.get_text()
	weather_text += Weather.weather_stat_mod.text
	%WeatherText.text = weather_text
	%Clock.text = timer.weather_clock


# Call every second, update timer
func _on_game_timer_timeout():
	#set_timer_text()
	$TimerLabel.text = timer.label_text
	%Clock.text = timer.weather_clock

#func set_timer_text():
	#$TimerLabel.text = timer.label_text
	#%Clock.text = timer.weather_clock
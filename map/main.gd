extends Node

signal game_start
signal api_request_complete

@export var use_api: bool = true  # Enable/disable api call
@export var enable_spawn : bool = true
@export var load_title : bool = true
@export var debug : bool = false


# API variables
@export var weather_interval : int = 10 # time between weather change in seconds

const api_url_format : String = "https://api.openweathermap.org/data/2.5/forecast?lat={latitude}&lon={longitude}&appid={key}"
var api_settings : Dictionary # settings loaded from config
var api_called: bool = false # if api has been called with current settings

var player : Character = null # current player object
const player_scn : PackedScene = preload("res://entity/player.tscn")
const enemy_scn : PackedScene = preload("res://entity/enemy/enemy.tscn")
const item_scn : PackedScene = preload("res://entity/item.tscn")
const enemy_lib : Resource = preload("res://libraries/enemy_lib.gd")
const make_node : Resource = preload("res://libraries/make_node.gd")

# Initial level
@export var player_level : int = 1
@export var enemy_level : int = 1

# Enemy variables
@export var enemy_spawn_time : int = 1	# Time between enemy spawns (s)
@export var enemy_spawn_count : int = 2	# Amount spawned
@export var enemy_level_interval : int = 15	# Time between incrementing enemy level (s)

@onready var gui : CanvasLayer = $GUI
@onready var spawn_timer : Timer = $EnemySpawnPath/SpawnTimer
@onready var window_size = $EnemySpawnPath.get_viewport_rect().size



func _init():
	if use_api:
		load_config()

# Called when the node enters the scene tree for the first time.
func _ready():
	if not load_title:
		start()

func get_gui():
	return gui

func load_config():
	api_called = false # api not called with new settings
	
	api_settings = {
		latitude=null,
		longitude=null,
		key=null,
		use_key=false,
	}
	
	# set api settings from config
	var config = ConfigFile.new()
	
	# load file
	if config.load("res://config.cfg") != OK:
		# if not loaded
		# set default location to first preset
		#if (api_settings.latitude == null or api_settings.longitude == null):
		var lat = Global.location_preset[0].lat
		var lon = Global.location_preset[0].lon
		api_settings.latitude = lat
		api_settings.longitude = lon
		
		# save settings
		Global.save_config_dict(api_settings)
	else:
		# set settings variable
		for setting in config.get_section_keys("API"):
			api_settings[setting] = config.get_value("API", setting)
	
	
	# set default api key if not in config
	if (api_settings.key == null):
		var file = FileAccess.open("res://api_key.txt", FileAccess.READ)
		var key = file.get_as_text().replace("\n","")
		api_settings.key = key
		file.close()
	else:
		api_settings.use_key = true
	
	Global.api_settings = api_settings
	
	print_debug(api_settings)



func start():
	Global.weather_interval = weather_interval
	
	# add new player
	player = make_node.new_player(player_level)
	add_child(player)
	gui.set_player(player)
	
	if(!api_called and use_api): api_call()
	api_called = true # don't call api again

	# set enemy spawn
	spawn_timer.wait_time = enemy_spawn_time
	spawn_timer.start()
	
	# start GUI and make pausable
	game_start.emit()
	Global.game_ongoing = true
	process_mode = Node.PROCESS_MODE_PAUSABLE


# Call API
func api_call():
	if(api_settings.key == null): return
	var api_url = api_url_format.format(api_settings)
	if $API.request(api_url) != OK: print_debug(":(")

func _on_api_request_completed(_result, response_code, _headers, body):
	#print_debug("API response: ", response_code)
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	Global.api_response_code = response_code
	Global.api_response = json.get_data()
	
	# if successful
	if(response_code == 200):
		Global.api_success = true
		#print_debug(Global.api_response.list[0])
		
		# datetime difference between responses
		Global.api_interval = (Global.api_response.list[1].dt - Global.api_response.list[0].dt)
	
	# set forecast then update gui
	Global.set_forecast()
	#print_debug(Global.forecast)
	api_request_complete.emit()

# Spawn n enemies
func enemy_spawn(n:int, level:int, move:bool=true): 
	if(player != null):
		for i in n:
			
			var spawn_location = %EnemySpawnLocation
			spawn_location.set_progress_ratio(randf()) # Select random location on path
			
			# offset location based on camera
			var position = spawn_location.position + player.get_screen_center()
			
			var target = null
			
			if move:
				target = player
			
			# get/add enemy
			var enemyInstance = make_node.new_enemy(level, position, target)
			enemyInstance.enemy_defeated.connect(_on_enemy_defeated)
			
			add_child(enemyInstance)

var timer = Global.level_timer
func _on_gui_time_update(): # Call every second when timer is running
	# Increase enemy level on interval
	if(enable_spawn and timer.total_seconds != 0 and timer.total_seconds % enemy_level_interval == 0):
		enemy_level += 1
		print_debug("enemy level ", enemy_level)

func _on_spawn_timer_timeout():
	if(enable_spawn): enemy_spawn(enemy_spawn_count, enemy_level)

func _on_gui_weather_changed():
	# update stats
	if(player != null):
		player.update_stats()
	get_tree().call_group("enemies", "update_stats")

# make item at position
func addItem(position:Vector2, ability:int=0):
	var item = make_node.new_item(ability)
	if item != null:
		item.set_deferred("global_position", position)
		item.set_ability(ability)
		add_child(item)

func game_over():
	Global.game_ongoing = false
	spawn_timer.stop()
	
	# disable player and enemies, delete items
	get_tree().call_group("character", "disable")
	get_tree().call_group("items", "queue_free")
	
	gui.game_over()

func _on_gui_game_start():
	start()

# restart
func _on_restart(reload_settings:bool = false):
	# delete player and enemies
	get_tree().call_group("character", "queue_free")
	
	player_level = 1
	enemy_level = 1
	
	# clear api response and reload settings
	if reload_settings: 
		Global.clear()
		gui.clear_forecast()
		load_config()
	
	start()

func _on_enemy_defeated(position, ability, xp):
	print_debug(ability)
	addItem(position, ability)
	player.gain_exp(xp)


# debug input
func _input(event):
	if debug and event.is_pressed():
		if is_instance_of(event, InputEventKey):
			var key = OS.get_keycode_string(event.keycode)
			#print(key)
			
			match key:
				"Q":
					get_tree().call_group("enemies", "_on_defeated")
					print_debug("enemies cleared")
				
				"W": enemy_spawn(1,enemy_level,false)
				"E":
					enable_spawn = !enable_spawn
					if enable_spawn: print_debug("spawn enabled")
					else: print_debug("spawn disabled")
				
				"A": 
					if player != null: player.gain_level(1)
					enemy_level += 1
				
				"S": if player!=null: player.gain_level(1)
				"D": enemy_level += 1
				"T": game_over()
				"R": _on_restart()
				"F": 
					var upgrade = Upgrade.new()
					upgrade.set_stat_upgrade("atk")
					print_debug(upgrade.stats)
					
					player.effects.print()
				"G": player.take_damage(1000)
				"X": player.projectile()
				"C": player.effects.new_ability(1)



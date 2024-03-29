extends Node

@export var use_api: bool = true  # Enable/disable api call
@export var weather_interval : int = 10 # time between weather change in seconds

# API variables
var api_settings : Dictionary # settings loaded from config
var api_called: bool = false # if api has been called with current settings
const api_url_format : String = "https://api.openweathermap.org/data/2.5/forecast?lat={latitude}&lon={longitude}&appid={key}"

var player : Character = null # current player object
const player_scn : PackedScene = preload("res://entity/player.tscn")
const enemy_scn : PackedScene = preload("res://entity/enemy/enemy.tscn")
const item_scn : PackedScene = preload("res://entity/item.tscn")
const enemy_lib : Resource = preload("res://libraries/enemy_lib.gd")

# Initial level
@export var player_level : int = 1
@export var enemy_level : int = 1

# Enemy variables
@export var enable_spawn : bool = true
@export var enemy_spawn_time : int = 1	# Time between enemy spawns (s)
@export var enemy_spawn_count : int = 2	# Amount spawned
@export var enemy_level_interval : int = 15	# Time between incrementing enemy level (s)

@onready var gui : CanvasLayer = $GUI
@onready var spawn_timer : Timer = $EnemySpawnPath/SpawnTimer
@onready var window_size = $EnemySpawnPath.get_viewport_rect().size

func _init():
	load_config()

func load_config():
	api_called = false # api not called with new settings
	
	api_settings = {
		latitude=null,
		longitude=null,
		key=null,
		custom_key=false,
	}
	
	# set api settings from config
	var config = ConfigFile.new()
	config.load("res://config.cfg")
	
	for setting in config.get_section_keys("API"):
		api_settings[setting] = config.get_value("API", setting)
	
	#print(str(api_settings))
	#print(api_settings.has("key"))
	#print(api_settings.key == null)
	
	# set default api key if not in config
	if (api_settings.key == null):
		var file = FileAccess.open("res://api_key.txt", FileAccess.READ)
		var key = file.get_as_text().replace("\n","")
		api_settings.key = key
		file.close()
	else:
		api_settings.custom_key = true
	
	Global.api_settings = api_settings
	print_debug(api_settings)

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.weather_interval = weather_interval
	
	# add new player
	player = player_scn.instantiate()
	add_child(player)
	
	player.gain_level(player_level-1)
	#print(player.global_position)
	
	if(!api_called): api_call()
	api_called = true # don't call api again

	# set enemy spawn
	spawn_timer.wait_time = enemy_spawn_time
	spawn_timer.start()
	
	# start GUI and make pausable
	gui.start()
	Global.game_ongoing = true
	process_mode = Node.PROCESS_MODE_PAUSABLE


# Call API
func api_call():
	if(api_settings.key == null):
		return
	
	var api_url = api_url_format.format(api_settings)
	#print_debug(api_url)
	
	var API = $API
	var request = API.request(api_url)
	if request != OK:
		print_debug(":(")
	else:
		print_debug("a")

func _on_api_request_completed(_result, response_code, _headers, body):
	print_debug("API response: ", response_code)
	
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
	print_debug(Global.forecast)
	gui.api_request_complete()

# Spawn n enemies
func enemy_spawn(n:int, level:int): 
	if(player != null):
		for i in n:
			var enemyInstance = enemy_scn.instantiate()
			var spawn_location = %EnemySpawnLocation
			
			enemyInstance.gain_level(level-1) # increase level
			
			spawn_location.set_progress_ratio(randf()) # Select random location on path

			# offset location based on camera
			#print(spawn_location.position)
			enemyInstance.set_target(player)
			enemyInstance.set_player(player)
			enemyInstance.set_deferred("position", spawn_location.position + player.get_screen_center())
			
			add_child(enemyInstance)

var timer = Global.level_timer
func _on_gui_time_update(): # Call every second when timer is running
	# Increase enemy level on interval
	if(timer.total_seconds != 0 && timer.total_seconds % enemy_level_interval == 0):
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
func addItem(position):
	var item = item_scn.instantiate()
	item.set_deferred("global_position", position)
	call_deferred("add_child", item)


func game_over():
	Global.game_ongoing = false
	spawn_timer.stop()
	
	# disable player and enemies, delete items
	get_tree().call_group("character", "disable")
	get_tree().call_group("items", "queue_free")
	
	gui.game_over()

# restart
func _on_restart(reload_settings:bool = false):
	# delete player and enemies
	get_tree().call_group("character", "queue_free")
	
	player_level = 1
	enemy_level = 1
	
	# clear api response and reload settings
	if reload_settings: 
		Global.clear()
		load_config()
	
	_ready()

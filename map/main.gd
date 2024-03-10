extends Node

@export var weather_interval : int = 10 # time between weather change in seconds

# API variables
@export var use_api: bool = true  # Enable/disable api call
var api_settings : Dictionary = {
	latitude=null,
	longitude=null,
	api_key=null
}
var api_url : String = ""
var api_url_format : String = "https://api.openweathermap.org/data/2.5/forecast?lat={latitude}&lon={longitude}&appid={api_key}"
var response = Global.api_response

var player : Character = null
const player_scn : PackedScene = preload("res://entity/player.tscn")
const enemy_scn : PackedScene = preload("res://entity/enemy.tscn")
const item_scn : PackedScene = preload("res://entity/item.tscn")

# Initialz level
@export var player_level : int = 1
@export var enemy_level : int = 1

# Enemy variables
@export var enable_spawn : bool = true
@export var enemy_spawn_time : int = 1	# Time between enemy spawns (s)
@export var enemy_spawn_count : int = 2	# Amount spawned
@export var enemy_level_interval : int = 15	# Time between incrementing enemy level (s)

@onready var gui : CanvasLayer = $GUI
@onready var spawn_timer : Timer = $EnemySpawnPath/SpawnTimer

func _init():
	# set api settings from config
	var config = ConfigFile.new()
	config.load("res://config.cfg")
	
	for setting in config.get_section_keys("API"):
		api_settings[setting] = config.get_value("API", setting)
	
	# set default api key if not in config
	if (api_settings.api_key == null):
		var file = FileAccess.open("res://api_key.txt", FileAccess.READ)
		var key = file.get_as_text().replace("\n","")
		api_settings.api_key = key
		file.close()

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.weather_interval = weather_interval
	
	
	# add new player
	player = player_scn.instantiate()
	add_child(player)
	player.gain_level(player_level-1)
	
	if(use_api): api_call()
	use_api = false # don't call api again
	
	# set enemy spawn
	spawn_timer.wait_time = enemy_spawn_time
	spawn_timer.start()
	
	# start GUI and make pausable
	gui.start()
	Global.game_ongoing = true
	process_mode = Node.PROCESS_MODE_PAUSABLE

# Call API
func api_call():
	if(api_settings.api_key == null):
		return
	
	api_url = api_url_format.format(api_settings)
	
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
		print_debug(Global.api_response.list[0])
		
		# datetime difference between responses
		Global.api_interval = (Global.api_response.list[1].dt - Global.api_response.list[0].dt)
	
	gui.weather_update()

func enemy_spawn(n, level): # Spawn n enemies
	#print_debug(level)
	if(player != null):
		for i in n:
			var enemyInstance = enemy_scn.instantiate()
			var spawn_location = %EnemySpawnLocation
			
			enemyInstance.gain_level(level-1)
			
			spawn_location.set_progress_ratio(randf()) # Select random location on path
			
			#print_debug("spawn ", spawn_location.position)
			
			# offset location based on player position
			enemyInstance.position = spawn_location.position + ($Player).position
			
			add_child(enemyInstance)

var timer = Global.level_timer
func _on_gui_time_update(): # Call every second when timer is running
	# Increase enemy level on interval
	if(timer.total_seconds != 0 && timer.total_seconds % enemy_level_interval == 0):
		enemy_level += 1
		print_debug("enemy level ", enemy_level)

func _on_spawn_timer_timeout():
	if(enable_spawn): enemy_spawn(enemy_spawn_count, enemy_level)

func game_over():
	Global.game_ongoing = false
	spawn_timer.stop()
	
	# delete player and enemies
	player.queue_free()
	get_tree().call_group("enemies", "queue_free")
	gui.game_over()

func _on_restart():
	player_level = 1
	enemy_level = 1
	_ready()

func _on_gui_weather_changed():
	# update stats
	if(player != null):
		player.update_stats()
	get_tree().call_group("enemies", "update_stats")

# make item at position
func addItem(position):
	var item = item_scn.instantiate()
	item.global_position = position
	add_child(item)

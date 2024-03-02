extends Node

@export var map_length = 5120 # Size of map
@warning_ignore("integer_division")
var map_size = Vector2(map_length/2,map_length/2)

@export var weather_interval = 45 # time between weather change in seconds

# API variables
@export var use_api = true  # Enable/disable api call
var api_settings = {
	latitude=null,
	longitude=null,
	api_key=null
}

var api_url_format = "https://api.openweathermap.org/data/2.5/forecast?lat={latitude}&lon={longitude}&appid={api_key}"

var api_url
var response = Global.api_response

var player
var player_scn = preload("res://entity/player.tscn")
var enemy_scn = preload("res://entity/enemy.tscn")
@export var spawn_time = 4
@export var enable_spawn = true

@onready var gui = $GUI
@onready var spawn_timer = $EnemySpawnPath/SpawnTimer

func _init():
	Global.map_size = map_length
	
	# set api settings from config
	var config = ConfigFile.new()
	config.load("res://config.cfg")
	print(config.get_section_keys("API"))
	
	for setting in config.get_section_keys("API"):
		api_settings[setting] = config.get_value("API", setting)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	Global.weather_interval = weather_interval
	
	# add new player
	player = player_scn.instantiate()
	add_child(player)
	
	if(use_api): api_call()
	use_api = false # don't call api again
	
	# set enemy spawn
	
	spawn_timer.wait_time = spawn_time
	spawn_timer.start()
	
	gui.start()

# Call API
func api_call():
	if(api_settings.api_key == null):
		return
	
	api_url = api_url_format.format(api_settings)
	print(api_url)
	
	var API = $API
	var request = API.request(api_url)
	if request != OK:
		print(":(")
	else:
		print("a")

func _on_api_request_completed(_result, response_code, _headers, body):
	print("API response: ", response_code)
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	Global.api_response_code = response_code
	Global.api_response = json.get_data()
	
	if(response_code == 200):
		Global.api_success = true
		
		# datetime difference between responses
		Global.api_interval = (Global.api_response.list[1].dt - Global.api_response.list[0].dt)
	
	gui.weather_update()

func enemy_spawn(n): # Spawn n enemies
	if(player != null):
		for i in n:
			var enemyInstance = enemy_scn.instantiate()
			var spawn_location = %EnemySpawnLocation
			
			spawn_location.set_progress_ratio(randf()) # Select random location on path
			
			print("spawn ", spawn_location.position)
			
			# offset location based on player position
			enemyInstance.position = spawn_location.position + ($Player).position
			
			add_child(enemyInstance)


func _on_spawn_timer_timeout():
	if(enable_spawn): enemy_spawn(spawn_time)

func game_over():
	player.queue_free()
	get_tree().call_group("enemies", "queue_free")
	gui.game_over()

func _on_restart():
	_ready()

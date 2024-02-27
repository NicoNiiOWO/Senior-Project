extends Node

@export var map_length = 5120 # Size of map
@warning_ignore("integer_division")
var map_size = Vector2(map_length/2,map_length/2)

# API variables
@export var latitude = 40.6500
@export var longitude = -73.9499
@export var api_key = "key"
@export var use_api = true  # Enable/disable api call

var api_url
var response = Global.api_response

var player_scn = preload("res://entity/player.tscn")
var enemy_scn = preload("res://entity/enemy.tscn")
@export var spawn_time = 4
@export var enable_spawn = true

@onready var gui = $GUI
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = player_scn.instantiate()
	add_child(player)
	player.call("setMap", map_length)
	
	if(use_api): api_call()
	
	var spawn_timer = $EnemySpawnPath/SpawnTimer
	spawn_timer.wait_time = spawn_time
	spawn_timer.start()
	
	gui.update_hud()

# Call API
func api_call():
	api_url = str("https://api.openweathermap.org/data/2.5/forecast?lat=",latitude,"&lon=",longitude,"&appid=",api_key)
	print(api_url)
	
	var API = $API
	var request = API.request(api_url)
	if request != OK:
		print(":(")
	else:
		print("a")

func _on_api_request_completed(result, response_code, _headers, body):
	print("API response: ", result, " ", response_code)
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	Global.api_response_code = response_code
	Global.api_response = json.get_data()
	
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

extends Node

@export var map_length = 5120 # Size of map
@warning_ignore("integer_division")
var map_size = Vector2(map_length/2,map_length/2)

# API variables
@export var latitude = 40.6500
@export var longitude = -73.9499
@export var api_key = "key"

var api_url
var response

var enemy = preload("res://entity/enemy.tscn")
@export var spawn_time = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.call("setMap", map_length)
	
	#api_call()
		
	var spawn_timer = $EnemySpawnPath/SpawnTimer
	spawn_timer.wait_time = spawn_time
	spawn_timer.start()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	#var player = $Player
	#var camera = $Player/Camera2D
	#
	#var enemy_spawn = $EnemySpawnPath
	
	#print(player.position, " ", player.get_position_delta())
	#
	#print(enemy_spawn.position)
	#enemy_spawn.position += player.get_position_delta() # Adjust spawn path based on player movement


func _on_player_ready():
	pass # Replace with function body.


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
		
	response = json.get_data()

	if response_code == 200: # Response successful
		print("Response Count: ",response.cnt)
		print(response.list[0])
	else:
		print(response.message)

func enemy_spawn(n): # Spawn n enemies
	for i in n:
		var enemyInstance = enemy.instantiate()
		var spawn_location = %EnemySpawnLocation
		
		spawn_location.set_progress_ratio(randf()) # Select random location on path
		
		print("spawn ", spawn_location.position)
		
		# offset location based on player position
		enemyInstance.position = spawn_location.position + ($Player).position
		
		add_child(enemyInstance)


func _on_spawn_timer_timeout():
	enemy_spawn(1)
	#($EnemySpawnPath/SpawnTimer).wait_time = 1

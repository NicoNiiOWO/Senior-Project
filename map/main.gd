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


var enemy_scene = "res://entity/enemy.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.call("setMap", map_length)
	
	api_url = str("https://api.openweathermap.org/data/2.5/forecast?lat=",latitude,"&lon=",longitude,"&appid=",api_key)
	print(api_url)
	
	# Call API
	var API = $API
	var request = API.request(api_url)
	if request != OK:
		print(":(")
	else:
		print("a")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_player_ready():
	pass # Replace with function body.


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

func enemy_spawn():
	var enemy = enemy_scene.instantiate()
	var spawn_location = $EnemySpawnLocation

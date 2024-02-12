extends Node

@export var map_length = 5000 # Size of map
var map_size = Vector2(map_length/2,map_length/2)

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.call("setMap", map_length)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_ready():
	pass # Replace with function body.

extends CharacterBody2D

@export var speed = 100
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = $/root/Main/Player



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = global_position.direction_to(player.global_position)
	#print(direction)
	
	velocity = direction * speed
	move_and_slide()

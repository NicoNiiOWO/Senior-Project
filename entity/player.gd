extends Area2D

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

var map_length # Size of map
var map_size

# Set size of map
func setMap(size):
	map_length = size
	map_size = Vector2(map_length/2,map_length/2)
	print_debug(map_size)
	
	# Set camera limit
	$Camera2D.set("limit_top", -map_length/2)
	$Camera2D.set("limit_left", -map_length/2)
	$Camera2D.set("limit_right", map_length/2)
	$Camera2D.set("limit_bottom", map_length/2)

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	print_debug("Screen size:", screen_size)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	position += velocity * delta
	position = position.clamp(-map_size, map_size)

	#print_debug(position)


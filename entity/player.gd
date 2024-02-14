extends CharacterBody2D

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
	velocity = Input.get_vector("move_left","move_right","move_up","move_down") # The player's movement vector.
	velocity = velocity * speed
	move_and_slide()
	
	var collision_count = get_slide_collision_count()
	if(collision_count > 0):
		print("Collisions: ", collision_count)
		for i in collision_count:
			var collision = get_slide_collision(i)
			print(collision.get_collider().name, " ", collision.get_collider_id())

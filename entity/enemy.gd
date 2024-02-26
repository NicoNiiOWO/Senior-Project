extends Character

var player

func _init():
	type = types.ENEMY
	speed = 100
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	player = $/root/Main/Player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	#print(direction)
	
	velocity = direction * speed
	move_and_slide()

# When HP reaches 0
func _on_defeated():
	queue_free()

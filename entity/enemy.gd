extends Character

@onready var player = $/root/Main/Player

func _init():
	init(Global.char_type.ENEMY) # initialize stats

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# move towards player
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * stats.speed
	move_and_slide()

# When HP reaches 0, give player exp and delete
func _on_defeated():
	player.gain_exp(stats.exp)
	queue_free()

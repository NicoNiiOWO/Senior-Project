extends Character

@onready var player = $/root/Main/Player

func _init():
	init(Global.char_type.ENEMY) # initialize stats

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	# move towards player
	if(player != null):
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * stats.speed
	else: velocity = Vector2.ZERO
	move_and_slide()
	
	var collision_count = get_slide_collision_count()
	if(collision_count > 0):
		#print("Collisions: ", collision_count)
		for i in collision_count:
			var collision = get_slide_collision(i)

			# check if player
			var isPlayer = false
			if("type" in collision.get_property_list()[0]):
				if collision.get_collider().type == Global.char_type.PLAYER:
					isPlayer = true
			
			if isPlayer:
				#print(str("E ", collision.get_collider().stats))
				if(player != null): player.take_damage(stats.atk)

# When HP reaches 0, give player exp and delete
func _on_defeated():
	player.gain_exp(stats.exp)
	queue_free()

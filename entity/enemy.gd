extends Character

var flip : bool = false
var target = null
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

func _init():
	init(Global.char_type.ENEMY) # initialize stats

func set_target(x:Node2D):
	target = x

func _ready():
	update_text()
	sprite.play("walk")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	# move towards target
	if(target != null):
		var direction = global_position.direction_to(target.global_position)
		velocity = direction * stats.speed
	else: velocity = Vector2.ZERO
	move_and_slide()
	
	var collision_count = get_slide_collision_count()
	if(collision_count > 0):
		#print_debug("Collisions: ", collision_count)
		for i in collision_count:
			var collision = get_slide_collision(i)

			# check if player
			var touchPlayer = false
			if("type" in collision.get_property_list()[0]):
				if collision.get_collider().type == Global.char_type.PLAYER:
					touchPlayer = true
			
			if touchPlayer:
				#print_debug(str("E ", collision.get_collider().stats))
				collision.get_collider().take_damage(stats.atk)
				
	# Flip sprite based on velocity
	if(velocity.x > 0): flip = false
	if(velocity.x < 0): flip = true
	
	if(sprite.flip_h != flip):
		sprite.flip_h = flip
		sprite.position.x = -sprite.position.x  # Flip offset to match hitbox

# Display level and hp
func update_text():
	var text = str("LVL ", stats.level, "\n")
	text += "%d/%d" % [stats.hp, stats.max_hp]
	%Label.text = text

# When HP reaches 0, give player exp and delete
func _on_defeated():
	get_tree().call_group("player", "gain_exp", stats.max_exp)
	#player.gain_exp(stats.max_exp)
	get_node("/root/Main").addItem(global_position) # drop heal item
	queue_free()

func _on_damage_taken():
	update_text()


extends CharacterBody2D

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

var map_length # Size of map
var map_size

var direction = Vector2(1,0) # player's direction, start facing right

@onready var sprite = $AnimatedSprite2D
var attack_scn = preload("res://entity/attack.tscn")
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
	
	
	if(velocity.x != 0 || velocity.y != 0): # Update direction only when moving
		direction = Vector2(round(velocity.x), round(velocity.y)) 
	
	velocity = velocity * speed

	move_and_slide()
	#print(direction)
	
	# Flip sprite if facing left
	var flip = false
	if(direction.x < 0): flip = true
	sprite.flip_h = flip
	
	# Set walk animation when moving
	if(sprite.animation != "attack"):
		if(velocity != Vector2.ZERO):
			sprite.play("walk")
		else:
			sprite.play("idle")
	
	# Attack
	if(Input.is_action_pressed("attack")):
		# attack if not on cooldown
		if(($AttackCooldown).is_stopped()):
			attack(flip)
			($AttackCooldown).start()
			sprite.play("attack")
			
			
	# get collision info
	var collision_count = get_slide_collision_count()
	if(collision_count > 0):
		print("Collisions: ", collision_count)
		for i in collision_count:
			var collision = get_slide_collision(i)
			print(collision.get_collider().name, " ", collision.get_collider_id())

func attack(flipped):
	var atk = attack_scn.instantiate()
	
	# Change attack position and rotate based on player direction
	atk.position += direction*30 + Vector2(0, -5)
	atk.global_rotation = Vector2.ZERO.angle_to_point(direction)
	if(flipped):
		atk.get_node("AnimatedSprite2D").flip_v = true
	#if()
	add_child(atk)
	pass


func _on_animated_sprite_2d_animation_finished():
	sprite.set_animation("idle")

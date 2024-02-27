extends Character

var screen_size # Size of the game window.

var map_length # Size of map
#var map_size

@export var direction = Vector2(1,0) # player's direction, start facing right
var flip = false # player sprite direction

@onready var sprite = $AnimatedSprite2D
var attack_scn = preload("res://entity/attack.tscn")
#var hud = preload("res://gui/hud.tscn")

func _init():
	init(Global.char_type.PLAYER)
	
	Global.player_stats = stats

# Gain exp and level
func gain_exp(n):
	stats.exp += n
	while stats.exp >= stats.max_exp:
		stats.level+=1
		stats.exp -= stats.max_exp
	
	update_stats()

# Calculate stats and update hud
func update_stats():
	var current_max_hp = stats.max_hp
	stats.max_hp = base_stats.max_hp + (stats.level-1) * stat_growth.max_hp
	stats.atk = base_stats.atk + (stats.level-1) * stat_growth.atk
	stats.max_exp = floor(base_stats.max_exp * pow(stat_growth.max_exp, (stats.level-1))) # exponential growth
	
	stats.hp += stats.max_hp - current_max_hp
	
	Global.player_stats = stats
	gui.update_hud()

# Set size of map
func setMap(map_size):

	# Set camera limit
	$Camera2D.set("limit_top", -map_size/2)
	$Camera2D.set("limit_left", -map_size/2)
	$Camera2D.set("limit_right", map_size/2)
	$Camera2D.set("limit_bottom", map_size/2)

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	print_debug("Screen size:", screen_size)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if(stats.iframes > 0):
		stats.iframes -= delta # reduce iframes by frametime
		if stats.iframes <= 0: stats.iframes = 0
	
	# Player movement
	velocity = Input.get_vector("move_left","move_right","move_up","move_down") # The player's movement vector.
	
	# Update direction facing when moving
	if(velocity.x != 0 || velocity.y != 0):
		var x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
		var y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
		
		if(x != 0 || y != 0): direction = Vector2(x,y)
		#if(round(velocity.x) != 0 && round(velocity.y) != 0):
			#direction = velocity.round() 
	
	velocity = velocity * stats.speed
	move_and_slide()

	# Flip sprite based on velocity
	if(velocity.x > 0): flip = false
	if(velocity.x < 0): flip = true
	
	if(sprite.flip_h != flip):
		sprite.flip_h = flip
		sprite.position.x = -sprite.position.x  # Keep offset for hitbox
	
	
	# Set walk animation when moving
	if(sprite.animation != "attack"):
		if(velocity != Vector2.ZERO):
			sprite.play("walk")
		else:
			sprite.play("idle")
			sprite.set_frame_progress(randf()) # Randomize idle
	
	# Attack when key is pressed
	if(Input.is_action_pressed("attack")):
		# attack if not on cooldown
		if(($AttackCooldown).is_stopped()):
			attack()
			($AttackCooldown).start()
			sprite.play("attack")


func attack():
	var new_attack = attack_scn.instantiate()
	new_attack.damage = stats.atk # change attack damage based on player atk stat
	
	# Change attack position and rotate based on player direction
	new_attack.position += direction*30 + Vector2(0, -5)
	new_attack.global_rotation = Vector2.ZERO.angle_to_point(direction)
	
	if(flip): # Flip sprite if player is flipped
		new_attack.get_node("AnimatedSprite2D").flip_v = true

	add_child(new_attack)


func _on_animated_sprite_2d_animation_finished():
	sprite.set_animation("idle")


func _on_defeated():
	#queue_free()
	main.game_over()
	print("AAA")

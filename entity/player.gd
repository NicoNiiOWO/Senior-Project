extends Character

var direction : Vector2 = Vector2(1,0) # player's direction, start facing right
var flip : bool = false # player sprite direction

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
var attack_scn : PackedScene = preload("res://entity/attacks/sword.tscn")
#var hud = preload("res://gui/hud.tscn")

func _init():
	init(Global.char_type.PLAYER)
	
	Global.player_stats = stats
	

# Gain exp and levels
func gain_exp(n:float):
	stats.exp += n
	
	var levels = 0
	while stats.exp >= stats.max_exp:
		levels+=1
		stats.exp -= stats.max_exp
		stats.max_exp *= stat_growth.max_exp
	
	gain_level(levels)

func heal(n:int):
	stats.hp += n;
	if(stats.hp > stats.max_hp):
		stats.hp = stats.max_hp
	update_stats()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set camera limit
	var map_size = Global.map_size
	$Camera2D.set("limit_top", -map_size/2.0)
	$Camera2D.set("limit_left", -map_size/2.)
	$Camera2D.set("limit_right", map_size/2.)
	$Camera2D.set("limit_bottom", map_size/2.)
	
	print_debug("Window size:", get_viewport_rect().size)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if(stats.iframes > 0):
		stats.iframes -= delta # reduce iframes by frametime
		if stats.iframes <= 0: stats.iframes = 0
	
	# Player movement
	velocity = Input.get_vector("move_left","move_right","move_up","move_down")
	
	# Update direction facing when moving
	if(velocity.x != 0 || velocity.y != 0):
		var x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
		var y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
		
		if(x != 0 || y != 0): direction = Vector2(x,y)
	
	velocity = velocity * stats.speed
	move_and_slide()

	# Flip sprite based on velocity
	if(velocity.x > 0): flip = false
	if(velocity.x < 0): flip = true
	
	if(sprite.flip_h != flip):
		sprite.flip_h = flip
		sprite.position.x = -sprite.position.x  # Flip offset to match hitbox
	
	
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
	# change damage/size based on player atk stat
	new_attack.init(direction, Global.char_type.PLAYER, stats.atk, stats.atk_size)
	add_child(new_attack)

func _on_animated_sprite_2d_animation_finished():
	sprite.set_animation("idle")

func _on_defeated():
	disable()
	main.game_over()
	print_debug("AAA")

# return center of screen
func get_screen_center() -> Vector2:
	return $Camera2D.get_screen_center_position()

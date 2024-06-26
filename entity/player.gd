class_name Player
extends Character

var direction : Vector2 = Vector2(1,0) # player's direction, start facing right
var flip : bool = false # player sprite direction

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
var attack_scn : PackedScene = preload("res://entity/attacks/sword.tscn")
#var hud = preload("res://gui/hud.tscn")

func _init():
	init(Global.char_type.PLAYER)
	
	#Global.player_stats = stats

# Gain exp and levels
func gain_exp(n:float):
	stats_r.gain_exp(n)
	update_stats()

func set_zoom(x:float):
	if is_node_ready():
		$Camera2D.zoom = Vector2(x,x)

func heal(n:int):
	stats_r.heal(n)
	update_stats()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_zoom(Config.display.zoom)
	
	# Set camera limit
	var map_size = Global.map_size
	$Camera2D.set("limit_top", -map_size/2.0)
	$Camera2D.set("limit_left", -map_size/2.)
	$Camera2D.set("limit_right", map_size/2.)
	$Camera2D.set("limit_bottom", map_size/2.)
	
	print_debug("Window size:", get_viewport_rect().size)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	effects.physics_update(delta) # update ability
	
	if(stats.iframes > 0):
		stats.iframes -= delta # reduce iframes by frametime
		if stats.iframes <= 0 and stats.iframes != -1: stats.iframes = 0
		gui.update_stats()
	
	# Player movement
	velocity = Input.get_vector("move_left","move_right","move_up","move_down")
	
	# Update direction facing when moving
	if(velocity.x != 0 || velocity.y != 0):
		var x = snappedi(velocity.normalized().x, 1)
		var y = snappedi(velocity.normalized().y, 1)
		
		#print(x, " ", y, " ", velocity.normalized())
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

func _on_attack(_x):
	var new_attack = attack_scn.instantiate()
	# change damage/size based on player atk stat
	new_attack.init(direction, Global.char_type.PLAYER, stats.atk, stats.atk_size)
	add_child(new_attack)
	
	%Attack.play()
	
	effects.on_attack() # update ability

func _on_animated_sprite_2d_animation_finished():
	sprite.set_animation("idle")

func _on_damage_taken(_x,_y,playSound=true):
	if playSound: %Hurt.play()

# return center of screen
func get_screen_center() -> Vector2:
	return $Camera2D.get_screen_center_position()

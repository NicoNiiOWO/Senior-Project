class_name Enemy
extends Character

const ability_list = enemy_lib.ability_type
var ability=0

var can_flip : bool = true # if sprite can flip
var flip : bool = false # flip sprite
var target : Node2D = null # node to move towards
var player : Character = null # player node
var direction : Vector2 # direction moving towards

enum states {WALK, ATTACK}
var state : Node
var attack_trigger=null # when to change state
var attacking = false

@onready var state_node : Dictionary = {
	states.WALK : $State/Walk,
	states.ATTACK : null,
}
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D


func _init():
	# set ability type based on current weather
	# default to cloudy
	var a = [1]
	if(Global.api_ready):
		a = enemy_lib.random_enemy_type(Global.currentWeather().type)
	else:
		a = enemy_lib.random_enemy_type([0])
	ability = a
	
	init(Global.char_type.ENEMY, ability) # initialize stats
	attack_trigger = enemy_lib.get_attack_trigger(ability)

# set current state (walk/attack)
func set_state(s:int):
	state = state_node[s]

# set target to move towards
func set_target(x:Node2D):
	target = x

func set_player(x:Character):
	player = x

# load ability and sprites
func load_ability(a:int):
	ability = a
	sprite.set_sprite_frames(enemy_lib.get_sprite(ability))
	
	var script = enemy_lib.get_attack_script(ability)
	# if ability has attack, set attack script
	if(script != null):
		# enable state
		state_node[states.ATTACK] = $State/Attack
		#state_node[states.ATTACK].set_process_mode(0)
		$State/Attack.set_script(script)
	
	# fix sprite position
	match ability:
		ability_list.TORNADO:
			can_flip = false
			sprite.position = Vector2(0,0)

func _ready():
	load_ability(ability)
	#sprite.set_sprite_frames(enemy_lib.get_sprite(ability))
	
	update_text()
	set_state(states.WALK)
	sprite.play("walk")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	state.physics_process() # movement based on current state
	move_and_slide()
	
	handle_collision()
	
	# Flip sprite based on velocity
	if can_flip:
		if(velocity.x > 0): flip = false
		if(velocity.x < 0): flip = true
		
		if(sprite.flip_h != flip):
			sprite.flip_h = flip
			sprite.position.x = -sprite.position.x  # Flip offset to match hitbox
	
	# call attack when near player
	if attack_trigger[0] == enemy_lib.attack_trigger.NEARPLAYER:
		if not attacking && global_position.distance_to(player.global_position) < attack_trigger[1]:
			attack()

# move towards target
func move(spd_mod:float = 1, curve_weight:float = 1):
	if target != null:
		move_towards(target, spd_mod, curve_weight)
	else: velocity = Vector2.ZERO

# move towards node, can curve
func move_towards(node:Node2D, spd_mod:float = 1, curve_weight:float = 1):
	var target_direction = global_position.direction_to(node.global_position)
	
	if(curve_weight != 0):
		direction.x = move_toward(direction.x, target_direction.x, curve_weight)
		direction.y = move_toward(direction.y, target_direction.y, curve_weight)
	
	velocity = direction * stats.speed*spd_mod


func handle_collision():
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
	
	# call attack when taking damage
	if attack_trigger[0] == enemy_lib.attack_trigger.TAKEDAMAGE:
		attack()

# set attack state/var
func attack(start:bool=true):
	attacking=start
	if start:
		set_state(1)
		state.attack()
	else:
		set_state(0)

class_name Enemy
extends Character

var ability=0

var flip : bool = false
var target : Node2D = null # node to move towards
var direction : Vector2 # direction towards node

enum states {WALK, ATTACK}
var state : Node

const ability_list = enemy_lib.ability_type

@onready var attack_state_list : Dictionary = {
	ability_list.NORMAL : null,
	ability_list.SWORD : $State/SwordAttack,
}

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
		a = enemy_lib.random_enemy_type(Global.weather_data.type)
	else:
		a = enemy_lib.random_enemy_type([0])
	ability = a
	
	init(Global.char_type.ENEMY, ability) # initialize stats

# set current state (walk/attack)
func set_state(s:int):
	state = state_node[s]

# set target for movement
func set_target(x:Node2D):
	target = x

# set ability and sprites
func set_ability(a:int):
	ability = a
	sprite.set_sprite_frames(enemy_lib.get_sprite(a))
	
	# if ability has attack, set attack state
	if(attack_state_list[a] != null):
		state_node[states.ATTACK] = attack_state_list[a]
		state_node[states.ATTACK].set_process_mode(0) # enable state 

func _ready():
	set_ability(ability)
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
	if(velocity.x > 0): flip = false
	if(velocity.x < 0): flip = true
	
	if(sprite.flip_h != flip):
		sprite.flip_h = flip
		sprite.position.x = -sprite.position.x  # Flip offset to match hitbox

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

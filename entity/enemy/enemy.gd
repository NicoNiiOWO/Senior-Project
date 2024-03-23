class_name Enemy
extends Character

var ability=0

var flip : bool = false
var target = null

enum states {WALK, ATTACK}
var state : Node

const enemy_lib = preload("res://libraries/enemy_lib.gd")
@onready var state_node : Dictionary = {
	states.WALK : $State/Walk,
	states.ATTACK : $State/Attack,
}
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

func _init():
	init(Global.char_type.ENEMY) # initialize stats

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

func _ready():
	# set ability type based on current weather
	var a = [0]
	if(Global.api_ready):
		a = enemy_lib.random_enemy_type(Global.weather_data.type)
	else:
		a = enemy_lib.random_enemy_type([0])
	set_ability(a)
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


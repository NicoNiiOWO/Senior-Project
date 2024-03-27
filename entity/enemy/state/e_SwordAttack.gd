extends Node

@export var startup_frame : int = 2; # animation frame when attack hitbox starts
var attack_scn : PackedScene = preload("res://entity/attacks/sword.tscn")
var sprite : AnimatedSprite2D

var direction : Vector2 # direction towards target
#var attacking = false

func _init():
	sprite = owner.sprite

func physics_process():
	# move towards target, lower speed
	if(owner.target != null):
		owner.move(0.3)
	else: owner.velocity = Vector2.ZERO

# start attack animation
func attack():
	sprite = owner.sprite
	#attacking = true
	sprite.play("attack")
	print_debug("pp")

# attack on frame of animation
func _on_animated_sprite_2d_frame_changed():
	if(owner.attacking && sprite.frame == startup_frame):
		var attack = attack_scn.instantiate()
		#print(owner.stats)
		attack.init(direction, 1, owner.stats.atk, owner.stats.atk_size)
		owner.add_child(attack)

# stop attacking at end of animation
func _on_animated_sprite_2d_animation_finished():
	if(sprite.animation == "attack"):
		sprite.play("walk")
		#attacking = false
		owner.attack(false)

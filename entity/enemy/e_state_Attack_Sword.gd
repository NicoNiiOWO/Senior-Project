extends Node

@export var startup_frame : int = 2; # animation frame when attack hitbox starts
var attack_scn : PackedScene = preload("res://entity/attacks/sword.tscn")
var sprite : AnimatedSprite2D

var attacking : bool = false # if is attacking
var direction : Vector2 # direction towards target

func physics_process():
	# move towards target, lower speed
	if(owner.target != null):
		direction = owner.global_position.direction_to(owner.target.global_position)
		owner.velocity = direction * owner.stats.speed/4
	else: owner.velocity = Vector2.ZERO

# start attack animation
func attack():
	sprite = owner.sprite
	sprite.play("attack")
	attacking = true

# on attack frame of animation
func _on_animated_sprite_2d_frame_changed():
	if(attacking && sprite.frame == startup_frame):
		var attack = attack_scn.instantiate()
		#print(owner.stats)
		attack.init(direction, 1, owner.stats.atk, 0.7)
		owner.add_child(attack)

# stop attacking at end of animation
func _on_animated_sprite_2d_animation_finished():
	if(sprite.animation == "attack"):
		sprite.play("walk")
		owner.set_state(0)
		attacking=false




extends Area2D

enum item_types{HEAL,UPGRADE}
var item_type : int;

#const stats_lib = preload("res://libraries/stats_lib.gd")

@export var duration = 15 # time before item disappears

@onready var sprite = $AnimatedSprite2D

var popup : bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	#var type = randi_range(0,1)
	#match type:
		#0: item_type = "heal"
		#1: item_type = "upgrade"
		#
	#sprite.animation = item_type
	$AnimatedSprite2D.frame = randi_range(3,12) # set random sprite
	$Timer.wait_time = duration-5
	$Timer.start()

# heal player
func _on_body_entered(body):
	if(is_instance_of(body, Player)):
		var gui = get_node("/root/Main/GUI")
		if popup and gui != null: gui.show_popup("aiuhjsfnhd")
		body.heal(10)
		queue_free()

# change transparency and delete after 5 seconds
func _on_timer_timeout():
	sprite.set_self_modulate(Color(1,1,1,0.5))
	await get_tree().create_timer(5.0, false).timeout
	queue_free()

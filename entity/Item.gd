extends Area2D

enum item_types{HEAL,UPGRADE}
var item_type : int;

const upgrade_lib = preload("res://libraries/upgrade_lib.gd")
var upgrades : Array = [] # list of upgrades
@export var duration = 15 # time before item disappears

@onready var sprite = $AnimatedSprite2D
@onready var gui = get_node("/root/Main/GUI")

var popup : bool = true

func set_ability(ability:int=0):
	item_type = 1
	upgrades = upgrade_lib.random_upgrade(ability,3)

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.frame = randi_range(3,12) # set random sprite
	$Timer.wait_time = duration-5
	$Timer.start()
	
	if upgrades.size() == 0:
		set_ability()

# heal player
func _on_body_entered(body):
	if(is_instance_of(body, Player)):
		if upgrades.size() > 0:
			if popup and gui != null : gui.upgrade_popup(upgrades)
		body.heal(10)
		queue_free()

# change transparency and delete after 5 seconds
func _on_timer_timeout():
	sprite.set_self_modulate(Color(1,1,1,0.5))
	await get_tree().create_timer(5.0, false).timeout
	queue_free()

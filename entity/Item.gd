extends Area2D

enum item_types{HEAL,UPGRADE}
const upgrade_lib = preload("res://libraries/upgrade_lib.gd")

var item_type : int = 0
var ability : int = 0
var upgrades : Array = [] # list of upgrades
@export var duration = 15 # time before item disappears

@onready var sprite = $AnimatedSprite2D
@onready var gui = get_node("/root/Main/GUI")

var popup : bool = true

func set_ability(abi:int=0):
	ability = abi
	item_type = 1
	
	if ability == 0:
		upgrades = upgrade_lib.random_upgrade(0,3)
	else:
		upgrades = upgrade_lib.random_upgrade(ability,1)
		upgrades.append_array(upgrade_lib.random_upgrade(0,2))

func set_sprite():
	if ability == 0: # set random sprite
		sprite.set_animation("heal")
		$AnimatedSprite2D.frame = randi_range(3,12)
	else:
		sprite.set_animation("ability")
		sprite.frame = ability
		sprite.scale *= 2

# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug(ability)
	set_sprite()
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

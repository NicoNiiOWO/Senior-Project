extends Area2D

@export var duration = 15 # time before item disappears

@onready var sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.frame = randi_range(3,12) # set random sprite
	$Timer.wait_time = duration-5
	$Timer.start()

# heal player
func _on_body_entered(body):
	if(body.has_method("heal")):
		#body.take_damage(200)
		body.heal(10)
		queue_free()

# change transparency and delete after 5 seconds
func _on_timer_timeout():
	sprite.set_self_modulate(Color(1,1,1,0.5))
	await get_tree().create_timer(5.0).timeout
	queue_free()

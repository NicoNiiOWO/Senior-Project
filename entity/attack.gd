extends Area2D

@export var duration = 0.25 # How long attack lasts
@export var damage = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = $Timer
	timer.wait_time = duration


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass


func _on_timer_timeout():
	queue_free() # Remove from memory 
	pass


func _on_body_entered(body):
	#print(body)
	if(body.has_method("take_damage")):
		body.take_damage(damage)

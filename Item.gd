extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.frame = randi_range(3,12) # set random sprite

# heal player
func _on_body_entered(body):
	if(body.has_method("heal")):
		body.heal(20)
		queue_free()

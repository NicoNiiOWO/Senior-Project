extends Node2D

var duration = 0.5
var dmg = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = str("-",dmg)
	await get_tree().create_timer(duration).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

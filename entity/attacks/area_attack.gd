class_name AreaAttack
extends Attack

@export var dmg_interval = 0.5 # damage every x seconds
@export var radius = 50
@export var color = Color(Color.AQUA, .2)
@export var shape : Shape2D = CircleShape2D.new()


func _init():
	if shape is CircleShape2D:
		shape.radius = radius

# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionShape2D.set_shape(shape)
	_draw()
	timer.start(dmg_interval)

func _draw():
	shape.draw(self.get_canvas_item(), color)

func _on_timer_timeout():
	damage_area()

func damage_area(): # damage characters in area
	for body in get_overlapping_bodies():
		if body is Character and body.type != source:
			body.take_damage(damage)

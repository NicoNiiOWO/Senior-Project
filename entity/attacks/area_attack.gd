class_name AreaAttack
extends Attack

@export var dmg_interval = 0.5 # damage every x seconds
@export var radius = 50 : set = _set_radius
@export var shape : Shape2D = CircleShape2D.new()

@export var color = Color(Color.AQUA, .1) : set = _set_color
@export var transparency : float = .2 : set = _set_transparency


func _set_radius(r:int):
	radius = r
	shape.radius = radius
	$CollisionShape2D.set_shape(shape)
	queue_redraw()

func _set_color(c:Color):
	color = Color(c,transparency)

func _set_transparency(t:float):
	transparency = t
	_set_color(color)

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_radius(radius)
	timer.start(dmg_interval)

func _draw():
	shape.draw(self.get_canvas_item(), color)


# damage characters in area
func _on_timer_timeout():
	damage_area()

func damage_area(): 
	for body in get_overlapping_bodies():
		if body is Character and body.type != source:
			body.take_damage(damage)

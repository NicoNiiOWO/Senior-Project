@tool
extends Node2D

@export var reset = false : set = _reset

@export var dmg = 0 : set = set_dmg

@export var offset : Vector2 = Vector2(0,-50) # position offset
@export var rand_radius : int = 10 # randomize position in radius

@export var duration = 0.5 # time before fade starts
@export var fade_time = 0.1
@export var fade:bool = false

func _reset(_x):
	set_modulate(Color(1,1,1,1))
	position=Vector2.ZERO
	fade = false

func set_dmg(x):
	dmg = x
	if is_node_ready():
		$Label.text = str("-",dmg)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_dmg(dmg)
	position+=offset
	randomize_position()
	await get_tree().create_timer(duration).timeout
	fade=true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if fade:
		var color = get_modulate()
		# delete if transparency is 0
		if color.a == 0: queue_free()
		
		# interpolate to transparent
		set_modulate(color.lerp(Color.TRANSPARENT, fade_time))

func randomize_position(radius=rand_radius):
	var r = Vector2(randf_range(-radius,radius), randf_range(-radius,radius))
	position += r

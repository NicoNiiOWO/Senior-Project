class_name Projectile
extends Attack

@export var direction : Vector2 = Vector2.ZERO
@export var speed : int = 400
var path : Path2D = null

func init_projectile(atk_source:int, dmg:float, size_m:float = 1.0, dur:float=1):
	init_attack(atk_source, dmg, size_m, dur)

# Called when the node enters the scene tree for the first time.
func _ready():
	start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_position += direction * delta * speed

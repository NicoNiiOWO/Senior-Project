class_name Projectile
extends Attack


@export var useOrbit : bool = false
@export var speed : int = 400

func init_projectile(atk_source:int, dmg:float, size_m:float = 1.0, dur:float=1):
	init_attack(atk_source, dmg, size_m, dur)

func orbit(radius:int):
	useOrbit=true
	position += Vector2(radius,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if useOrbit: position = position.rotated(delta*speed/100)
	else: position += direction.normalized() * speed * delta 

func set_sprite(texture:SpriteFrames, animation="", frame=0):
	sprite.sprite_frames = texture
	if animation != "":
		sprite.animation = animation
		sprite.frame = frame

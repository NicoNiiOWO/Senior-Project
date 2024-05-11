extends Path2D


# Called when the node enters the scene tree for the first time.
# set path around window
func _ready():
	print(get_viewport_rect())
	var window = get_viewport_rect().size/2
	$EnemySpawnLocation.position = -window
	
	curve.add_point(Vector2(-window.x, -window.y))
	curve.add_point(Vector2(window.x, -window.y))
	curve.add_point(Vector2(window.x, window.y))
	curve.add_point(Vector2(-window.x, window.y))
	curve.add_point(Vector2(-window.x, -window.y))
	
	$Line2D.points = PackedVector2Array(curve.get_baked_points())

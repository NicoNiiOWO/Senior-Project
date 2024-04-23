extends Attack

func init(atk_source:int, dmg:float, size_m:float = 1, dur:float=2.0):
	init_attack(atk_source, dmg, size_m, dur)

# Called when the node enters the scene tree for the first time.
func _ready():
	start()


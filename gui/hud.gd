extends CanvasLayer


func update():
	var HP = $HP
	var stats = Global.player_stats
	
	HP.text = str("HP: ", stats.hp,"/", stats.max_hp)
	($Level).text = str("Level: ", stats.level, " EXP: ", stats.exp, "/", stats.max_exp)

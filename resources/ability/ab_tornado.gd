extends Ability

func _init():
	level_changed.connect(reload)

func reload():
	pass

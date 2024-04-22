extends Ability


func on_attack():
	print_debug("AAAA")

func _init():
	#level_changed.connect()
	pass

func get_next_lvl_text(lvl=self.level):
	print_debug("e",lvl)
	if lvl == 0:
		return super.get_next_lvl_text()
	else: return str("AAAAA ", level+1)

func on_level_changed():
	print_debug("changed")

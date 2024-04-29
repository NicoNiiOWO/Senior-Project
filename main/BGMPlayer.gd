extends AudioStreamPlayer

const file_path = "res://assets/sounds/bgm/"

var bgm_list : Array = []
var bmg_loop : Dictionary = {}
var current_bgm : int = -1 : set = set_bgm # index of current bgm

# load all bgm in folder to array
func _init():
	for filename in DirAccess.get_files_at(file_path):
		if filename.ends_with(".wav"):
			var file = load(file_path + filename)
			bgm_list.append(file)

# Called when the node enters the scene tree for the first time.
func _ready():
	random_bgm()

# set random bgm
func random_bgm(allow_repeat:bool=true):
	if bgm_list.size() > 0:
		var i = randi_range(0, bgm_list.size()-1)
		
		if not allow_repeat and i == current_bgm:
			i += 1
			if i == bgm_list.size(): i = 0
		
		# change bgm if selected is different
		if i != current_bgm: set_bgm(i)

func set_bgm(i):
	set_stream(bgm_list[i])
	play()
	current_bgm = i

func _on_main_restart():
	random_bgm(false)

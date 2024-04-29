extends AudioStreamPlayer

const file_path = "res://assets/sounds/bgm/"

var bgm_list : Array = []
var current_bgm : int = -1 # index of current bgm

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
func random_bgm():
	if bgm_list.size() > 0:
		var i = randi_range(0, bgm_list.size()-1)
		
		# change bgm if index is different
		if i != current_bgm: set_bgm(i)

func set_bgm(i):
	set_stream(bgm_list[i])
	play()
	current_bgm = i

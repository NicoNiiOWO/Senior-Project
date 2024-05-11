extends Node

const make_node = preload("res://libraries/make_node.gd")

enum char_type {PLAYER, ENEMY} # use to initialize character
var char_type_str : Array = ["Player", "Enemy"]

var game_ongoing : bool = false # if game is started and not over
var game_paused : bool = false

var map_size : int = 5120 # size of map

var bgm : AudioStreamPlayer = null
var player : Player = null

var timer : GameTimer = GameTimer.new()

func new_player(level=1):
	player = make_node.new_player(level)

func set_bgm_node(node:AudioStreamPlayer):
	bgm = node

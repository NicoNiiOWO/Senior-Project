extends Node

signal game_start
signal restarted
signal api_request_complete

@export var debug : bool = false
@export var use_api: bool = true  # Enable/disable api call
@export var enable_spawn : bool = true
@export var load_title : bool = true
@export var sound_on : bool = true


# API variables
@export var weather_interval : int = 10 # time between weather change in seconds

const api_url_format : String = "https://api.openweathermap.org/data/2.5/forecast?lat={latitude}&lon={longitude}&appid={key}"
var api_called: bool = false # if api has been called with current settings

var player : Character = null # current player object
const make_node : Resource = preload("res://libraries/make_node.gd")

# Initial level
@export var player_level : int = 1
@export var enemy_level : int = 1

# Enemy variables
@export var enemy_spawn_time : int = 2	# Time between enemy spawns (s)
@export var enemy_spawn_count : int = 1	# Amount spawned
@export var enemy_level_interval : int = 15	# Time between incrementing enemy level (s)

@onready var game : Node = $Entities
@onready var gui : CanvasLayer = $GUI
@onready var window_size = $EnemySpawnPath.get_viewport_rect().size
@onready var timer : GameTimer = Global.timer


func _init():
	if use_api:
		load_config()

# Called when the node enters the scene tree for the first time.
func _ready():
	Weather.forecast_end.connect(win) # call win() at end of forecast
	Weather.weather_updated.connect(_on_weather_updated)
	
	Weather.weather_interval = weather_interval
	Global.set_bgm_node($BGMPlayer)
	Config.apply_volume(sound_on)
	
	add_child(timer)
	timer.game_timeout.connect(_on_timer_timeout)
	
	if use_api: api_call()
	
	if not load_title:
		start()
	else:
		$GUI.open_title()

func get_gui(): return gui

func load_config():
	api_called = false # api not called with new settings
	Config.load_config()

func start(save_settings:bool = false):
	clear_entities()
	if save_settings: reload_settings()
	
	Weather.weather_interval = weather_interval
	
	# add new player
	Global.new_player(player_level)
	player = Global.player
	player.defeated.connect(game_over)
	
	game.add_child(player)
	player.update_stats()
	
	gui.set_player(player)
	
	if(!api_called and use_api): api_call() # call api if not already called
	
	
	# start GUI and make pausable
	Global.timer.reset()
	Global.timer.start()
	game_start.emit()
	
	Global.game_ongoing = true
	process_mode = Node.PROCESS_MODE_PAUSABLE


# Call API
func api_call():
	if(Config.api_settings.key == null): return
	var api_url = api_url_format.format(Config.api_settings)
	
	if $API.request(api_url) != OK: print_debug(":(")
	api_called = true

func _on_api_request_completed(_result, response_code, _headers, body):
	Weather.handle_response(response_code, body)
	api_request_complete.emit()

# Spawn n enemies
func enemy_spawn(n:int, level:int, move:bool=true, near_player:bool=false, ability:int=-1): 
	if(player != null):
		for i in n:
			
			var spawn_location = %EnemySpawnLocation
			spawn_location.set_progress_ratio(randf()) # Select random location on path
			
			# offset location based on camera
			var position = spawn_location.position + player.get_screen_center()
			
			if near_player: position = player.get_screen_center() + Vector2(100, 0)
			
			var target = null
			
			target = player
			
			
			# get/add enemy
			var enemyInstance = make_node.new_enemy(level, position, target, ability) as Enemy
			enemyInstance.enemy_defeated.connect(_on_enemy_defeated)
			
			enemyInstance.can_move = move
			game.add_child(enemyInstance)
			
			#print_debug(enemyInstance.stats)
			enemyInstance.update_stats()

func _on_timer_timeout(): # Call every second when timer is running
	# Increase enemy level on interval
	
	if enable_spawn and timer.total_seconds != 0:
		if(timer.total_seconds % enemy_level_interval == 0):
			enemy_level += 1
			print_debug("enemy level ", enemy_level)
		
		if timer.total_seconds % enemy_spawn_time == 0:
			enemy_spawn(enemy_spawn_count, enemy_level)

# update stats when weather changes
func _on_weather_updated():
	if(player != null):
		player.update_stats()
	get_tree().call_group("enemies", "update_stats")

# make item at position
func addItem(position:Vector2, ability:int=0):
	var item = make_node.new_item(ability)
	if item != null:
		item.set_deferred("global_position", position)
		item.set_ability(ability)
		game.call_deferred("add_child", item)

func stop():
	Global.game_ongoing = false
	timer.clear()
	
	# disable player and enemies, delete items
	get_tree().call_group("character", "disable")
	get_tree().call_group("items", "queue_free")

func win():
	game_over(true)
	
func game_over(w=false):
	stop()
	gui.game_over(w)

# title screen start button
func _on_gui_game_start():
	start()

# restart button
func _on_restart(save_settings:bool = false):
	#clear_entities()
	
	player_level = 1
	enemy_level = 1
	
	# clear api response and reload settings
	if save_settings: 
		reload_settings()
	
	Weather.restart()
	
	restarted.emit()
	start()

func clear_entities():
	stop()
	# delete characters and items
	get_tree().call_group("character", "queue_free")
	get_tree().call_group("items", "queue_free")
	for child in game.get_children(): # delete remaining nodes
		child.queue_free()

# clear forecast and load config file
func reload_settings():
	Weather.clear()
	gui.clear_forecast()
	load_config()

# add item, give player xp, play sound at position
func _on_enemy_defeated(position, ability, xp):
	addItem(position, ability)
	player.gain_exp(xp)
	
	$CharDefeatSFX.global_position = position
	$CharDefeatSFX.play()


# debug input
func _input(event):
	if debug and event.is_pressed():
		if is_instance_of(event, InputEventKey):
			var key = OS.get_keycode_string(event.keycode)
			#print(key)
			
			match key:
				"1": enemy_spawn(1,enemy_level,false, true, 0)
				"2": enemy_spawn(1,enemy_level,false, true, 1)
				"3": enemy_spawn(1,enemy_level,false, true, 2)
				"4": enemy_spawn(1,enemy_level,false, true, 3)
				"Q":
					get_tree().call_group("enemies", "_on_defeated")
					print_debug("enemies cleared")
				
				"W": enemy_spawn(1,enemy_level,false, true)
				"E":
					enable_spawn = !enable_spawn
					if enable_spawn: print_debug("spawn enabled")
					else: print_debug("spawn disabled")
				
				"A": 
					if player != null: player.gain_level(1)
					enemy_level += 1
				
				"S": if player!=null: player.gain_level(1)
				"D": enemy_level += 1
				"T": game_over()
				"R": _on_restart()
				"F": addItem(player.position, -1)
				"G": player.take_damage(1000)
				"C": player.effects.new_ability(1)
				"H": player.heal(5)
				"M": $BGMPlayer.next()
				#"Kp Add": Weather.increment()



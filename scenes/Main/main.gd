extends Node
@onready var game_camera: Camera2D = $GameCamera
@onready var current_tile_map_layer: TileMapLayer = %CurrentTileMapLayer
@onready var tile_map_manager: TileMapManager = %TileMapManager
@onready var upgrade_manager: Node = %UpgradeManager
@export var end_screen_scene:PackedScene

var pause_menu_scene = preload("res://scenes/Ui/PauseMenu.tscn")
var run_inventory_scene = preload("res://scenes/Ui/run_inventory_menu.tscn")
var blur_vignette_scene = preload("res://scenes/Ui/blur_vignette.tscn")
var active_map:Map

func _ready():
	# Connection stuff6
	GameEvents.door_to_next_area_should_open.connect(on_door_should_be_open)
	%Player.health_component.health_owner_died.connect(on_player_died)
	
	# Playing the reset animation for the vignette
	%Vignette.animation_player.play("RESET")
	
	# Switching the music back to normal
	MusicPlayer.switch_music_momentum_to(1)
	
	# Getting the last played map 
	active_map = MapManager.get_active_map()
	
	# Set the Meta progression stuff
	MetaProgression.player_healed_this_run = false
	MetaProgression.player_did_not_pick_own_cards_during_run = true
	MetaProgression.player_score = 0
	
	# Setting up specific stuff related to the active map
	setup_specific_map_stuff(active_map)
	
	# Resetting the values fr om the modifiers
	ModifierManager.reset_modifier_values()
	
	# Applying the new modifier values
	apply_modifiers(active_map)

func setup_specific_map_stuff(active_map:Map) -> void:
	var upcoming_tile_map_layer:TileMapLayer = tile_map_manager.get_tile_layer_for_map(active_map.id)
	if(upcoming_tile_map_layer != null):
		current_tile_map_layer.tile_set = upcoming_tile_map_layer.tile_set
		current_tile_map_layer.tile_map_data = upcoming_tile_map_layer.tile_map_data
		# Use the ObjectSpawnManager to spawn in the objects 
		#(id to know which one, map id to know in which folder or settings that need to be applied 
		# and global pos to know where)
		# code
		pass
	if(active_map.map_objects.size() > 0):
		for map_object:MapObject in active_map.map_objects:
			pass 	
	MusicPlayer.play_requested_track(active_map.music_track_name,active_map.base_volume_of_track)
	MetaProgression.increase_games_played_by(1,active_map.id)
	
func apply_modifiers(active_map:Map) -> void:
	var active_modifiers_ids:Array[String] = active_map.get_active_modifiers()
	# if the map has any active unlocked modifiers
	if(active_modifiers_ids != null and active_modifiers_ids.size() > 0):
		 # Loop through them
		for active_modifier_id:String in active_modifiers_ids:
			ModifierManager.execute_modifier(active_map.id, active_modifier_id)
			
func on_player_died():
	MusicPlayer.stop()
	# Slight delay so player can see themselves die
	await get_tree().create_timer(1.0, true).timeout 
	%Vignette.animation_player.play("RESET")
	MusicPlayer.volume_db = MusicPlayer.base_volume
	var defeat_screen_instance = end_screen_scene.instantiate() as EndScreen
	defeat_screen_instance.did_player_win_game = false
	get_tree().get_first_node_in_group("foreground").add_child(defeat_screen_instance)
	defeat_screen_instance.set_to_defeat_screen()
	MetaProgression.save()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		pause_game()
	elif event.is_action_pressed("open_run_inventory"):
		open_run_inventory()
		
func pause_game() -> void:
	add_child(blur_vignette_scene.instantiate())
	add_child(pause_menu_scene.instantiate())
	get_tree().root.set_input_as_handled()
	MusicPlayer.volume_db -= 5

func open_run_inventory() -> void:
	var run_inventory_instance = run_inventory_scene.instantiate()
	run_inventory_instance.upgrades_on_screen = upgrade_manager.upgrades_in_current_run
	add_child(run_inventory_instance)
	get_tree().root.set_input_as_handled()
	MusicPlayer.volume_db -= 5

func on_door_should_be_open() -> void:
	var next_area = get_tree().get_first_node_in_group("next_area_door") as NextArea
	# Lower volume of audio
	MusicPlayer.volume_db -= 5
	## Pause game
	get_tree().paused = true
	# Move camera to door
	game_camera.go_to(next_area.global_position)
	await get_tree().create_timer(0.5).timeout
	# Do the door stuff
	next_area.animation_player.play("reveal_door")
	await next_area.animation_player.animation_finished
	await get_tree().create_timer(0.5).timeout
	# Move camera back to player
	game_camera._aqcuire_target()
	## Unpause
	get_tree().paused = false
	MusicPlayer.volume_db += 5

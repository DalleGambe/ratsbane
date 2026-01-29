extends CanvasLayer

var options_scene = preload("res://scenes/Ui/OptionsMenu.tscn")

@onready var build_label: Label = %BuildLabel
@onready var time_played: Label = %TimeLabel
@onready var playtime_label: Label = %PlaytimeLabel

func _ready() -> void:
	build_label.text = MetaProgression.build_version
	if(MetaProgression.is_beta == true):
		build_label.text +="-beta -"
	else:
		build_label.text +="-alpha -"		
	%QuickPlayButton.pressed.connect(on_quick_play_button_pressed)
	%PlayButton.pressed.connect(on_play_button_pressed)
	%UpgradesButton.pressed.connect(on_upgrades_button_pressed)
	%AchievementsButton.pressed.connect(on_achievements_button_pressed)
	%OptionsButton.pressed.connect(on_options_button_pressed)
	%FeedbackButton.pressed.connect(on_feedback_button_pressed)
	%QuitButton.pressed.connect(on_quit_button_pressed)
	var main_menu_track = "hear_what_they_say"
	if(main_menu_track not in MusicPlayer.track_playing):
		MusicPlayer.switch_music_momentum_to(1)
		MusicPlayer.play_requested_track(main_menu_track)

func _process(delta: float) -> void:
	playtime_label.text = tr(Util.convert_to_time_hour(MetaProgression.get_total_playtime()))
	
func on_quick_play_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/Ui/MapSelectScreen/ModifierSelectionMenu.tscn")	

func on_play_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/Ui/MapSelectScreen/MapSelectionMenu.tscn")	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		get_tree().quit()

func on_upgrades_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/Ui/MetaMenu.tscn")	

func on_achievements_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/Ui/AchievementMenu.tscn")	

func on_options_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	var options_instance = options_scene.instantiate()
	add_child(options_instance)
	options_instance.pressed_back_button.connect(on_back_button_pressed.bind(options_instance))
	
func on_quit_button_pressed() -> void:
	get_tree().quit()	

func on_feedback_button_pressed() -> void:
	# Show pop up
	# await for response
	# If response is yes, open feedack form
	OS.shell_open(tr("FEEDBACK_FORM_URI"))
	# Close form
	
func on_back_button_pressed(menu_instance:Node) -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	menu_instance.queue_free()

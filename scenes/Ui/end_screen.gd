extends CanvasLayer
class_name EndScreen

@onready var panel_container = %PanelContainer
@onready var restart_button = %RestartButton
@onready var upgrades_button: Button = %UpgradesButton
@onready var quit_button = %QuitButton
@onready var title_label: AnimatedLabel = %TitleLabel
@onready var score_label: Label = %ScoreLabel
@onready var achievements_button: Button = %AchievementsButton
@onready var player_lasted_label: Label = %PlayerLastedLabel
@export var did_player_win_game: bool = false

var show_best_score_text = ""
var show_best_time_text = ""

const leaderboard_submission_screen = preload("res://scenes/Ui/leaderboard_submission_screen.tscn")

func _ready() -> void:
	MusicPlayer.stop()
	panel_container.pivot_offset = panel_container.size / 2
	restart_button.pressed.connect(_on_restart_button_pressed)
	achievements_button.pressed.connect(_on_achievements_button_pressed)
	upgrades_button.pressed.connect(_on_upgrades_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
		
	if(MetaProgression.is_best_map_score(MetaProgression.player_score)):
		show_best_score_text = "(" + tr("BEST_LABEL") + "!) "
		
	if(MetaProgression.is_best_map_time(MetaProgression.player_lasted_time_in_seconds)):
		show_best_time_text = "(" + tr("BEST_LABEL") + "!) "
	
	MetaProgression.increase_meta_stats(did_player_win_game)

	# Get the saved score from the arena UI somehow
	score_label.text = tr(score_label.text) + ": " + str(MetaProgression.player_score) + show_best_score_text
	player_lasted_label.text = tr("VICTORY_TIME_IN_ARENA_LABEL") + ": " + Util.convert_to_time(MetaProgression.player_lasted_time_in_seconds) + show_best_time_text
	
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0.6)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_BOUNCE)
	tween.chain()
		
	if(LeaderboardManager.get_lowest_score_on_leaderboard(MetaProgression.currently_playing_on)["score"]  < MetaProgression.player_score):
		var leaderboard_submission_screen_instance = leaderboard_submission_screen.instantiate()
		get_tree().get_first_node_in_group("foreground").add_child(leaderboard_submission_screen_instance)
	
	MenuManager._add_menu_to_list(self)
	get_tree().paused = true

func _exit_tree():
	MenuManager._remove_menu_from_list(self)
	
func _on_restart_button_pressed() -> void:
	MenuManager.clear_menu_list()
	transition_to("res://scenes/Main/main.tscn")
	
func play_jingle(name_jingle:String) -> void:
	%JinglePlayer.play_random_audio(name_jingle)
	await %JinglePlayer.finished
			
func set_to_defeat_screen() -> void:
	title_label.text = "DEFEAT_LABEL"
	title_label._set_text(title_label.text)
	player_lasted_label.text = tr("DEFEAT_TIME_IN_ARENA_LABEL") + ": " + Util.convert_to_time(MetaProgression.player_lasted_time_in_seconds) + show_best_time_text
	%DescriptionLabel.text = "DEFEAT_DESCRIPTION"
	play_jingle("defeat")

func _on_upgrades_button_pressed() -> void:
	MenuManager.clear_menu_list()
	MusicPlayer.switch_music_momentum_to(1)
	MusicPlayer.play_requested_track("hear_what_they_say")
	transition_to("res://scenes/Ui/MetaMenu.tscn")

func _on_achievements_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	MusicPlayer.switch_music_momentum_to(1)
	MusicPlayer.play_requested_track("hear_what_they_say")
	transition_to("res://scenes/Ui/AchievementMenu.tscn")	

func _on_quit_button_pressed() -> void:
	MenuManager.clear_menu_list()
	transition_to("res://scenes/Ui/MainMenu.tscn")

# Making pausing on the screen not work
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		pass
	
func transition_to(path:String) -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	MusicPlayer.play()
	get_tree().paused = false
	get_tree().change_scene_to_file(path)		

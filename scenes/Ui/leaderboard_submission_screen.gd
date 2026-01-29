extends CanvasLayer

@onready var submit_score_button: Button = %SubmitScoreButton
@onready var panel_container: PanelContainer = %PanelContainer

func _ready() -> void:
	MenuManager._add_menu_to_list(self)
	panel_container.pivot_offset = panel_container.size / 2
	submit_score_button.pressed.connect(on_submit_score_button_pressed)
	%PlayerNameInputField.text = LeaderboardManager.get_last_leaderboard_player_name()
	MetaProgression.player_score
	MetaProgression.player_lasted_time_in_seconds		

	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0.6)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_BOUNCE)
	tween.chain()

func _exit_tree():
	MenuManager._remove_menu_from_list(self)

func on_submit_score_button_pressed() -> void:
	if(%PlayerNameInputField.text != ""):
		# Save score
		LeaderboardManager.save_leaderboard_score(%PlayerNameInputField.text, MetaProgression.player_score, MetaProgression.player_lasted_time_in_seconds)
		
		# Close this pop up
		MenuManager._remove_menu_from_list(self)
		var tween = create_tween()
		tween.tween_property(panel_container, "scale", Vector2.ONE, 0)
		tween.tween_property(panel_container, "scale", Vector2.ZERO, 0.3)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_BACK)
		tween.tween_callback(queue_free)

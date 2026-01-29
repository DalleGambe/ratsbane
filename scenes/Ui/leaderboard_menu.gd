extends CanvasLayer

@onready var leaderboard_scores: Array
@onready var grid_container: GridContainer = %GridContainer
@onready var back_button: Button = %BackButton
@onready var filter_leaderboard_options_button: OptionButton = %FilterLeaderboardOptionsButton

const leaderboard_score_card_scene = preload("res://scenes/Ui/leaderboard_player_score_card.tscn")

func _ready() -> void:
	filter_leaderboard_options_button.add_item("General", 0)
	#for map in MapManager.get_maps():
		#filter_leaderboard_options_button.add_item(map.title, map.number_id)

	leaderboard_scores = MetaProgression.get_saved_leaderboard_scores("general")
	# Remove the test cards
	for child in grid_container.get_children():
		child.queue_free()

	var player_ranking = 0
	back_button.pressed.connect(on_back_button_pressed)
	leaderboard_scores.sort_custom(func(ranking_a, ranking_b): return ranking_a["score"] > ranking_b["score"])
	
	for leaderboard_score in leaderboard_scores:
		player_ranking += 1
		var leaderboard_score_card_instance = leaderboard_score_card_scene.instantiate()
		grid_container.add_child(leaderboard_score_card_instance)
		leaderboard_score_card_instance.set_player_score(leaderboard_score, player_ranking)

func on_back_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/Ui/AchievementMenu.tscn")	

#func on_filter_leaderboard_options_button_item_selected(index: int) -> void:
	#var map_id:String = MapManager.get_map_id_through_number_id(index)
	#if(index != 0 && map_id.is_empty()):
		#filter_leaderboard_options_button.selected = 0
	#leaderboard_scores = MetaProgression.get_saved_leaderboard_scores(map_id)
	#for child in grid_container.get_children():
		#child.queue_free()
	
	#var player_ranking = 0	
	#for leaderboard_score in leaderboard_scores:
		#player_ranking += 1
		#var leaderboard_score_card_instance = leaderboard_score_card_scene.instantiate()
		#grid_container.add_child(leaderboard_score_card_instance)
		#leaderboard_score_card_instance.set_player_score(leaderboard_score, player_ranking)	

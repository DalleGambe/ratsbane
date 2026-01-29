extends Node

func save_leaderboard_score(player_name:String, high_score:float, time_played_in_seconds:int) -> void:
	var map_name = MetaProgression.currently_playing_on
	# Replace lowest score on leadeboard
	var lowest_score = get_lowest_score_on_leaderboard()
	# Set new placeholder with playername
	MetaProgression.save_data["leaderboard"]["leaderboard_last_player_name"] = player_name
	# Save actual score in meta progression
	MetaProgression.save_data["leaderboard"]["leaderboard_scores"][map_name][lowest_score.ranking_id]["id"] = generate_player_id(player_name)
	MetaProgression.save_data["leaderboard"]["leaderboard_scores"][map_name][lowest_score.ranking_id]["player_name"] = player_name
	MetaProgression.save_data["leaderboard"]["leaderboard_scores"][map_name][lowest_score.ranking_id]["score"] = high_score
	MetaProgression.save_data["leaderboard"]["leaderboard_scores"][map_name][lowest_score.ranking_id]["time_played"] = Util.convert_to_time_hour(time_played_in_seconds)
	MetaProgression.save_data["leaderboard"]["leaderboard_scores"][map_name][lowest_score.ranking_id]["date"] = Util.get_formatted_date()
	MetaProgression.save_data["leaderboard"]["leaderboard_scores"][map_name][lowest_score.ranking_id]["game_version"] = MetaProgression.build_version
	
func get_lowest_score_on_leaderboard(map_played_on:String=""):
	var lowest_score;
	for leaderboard_score in MetaProgression.get_saved_leaderboard_scores(map_played_on):
		if(lowest_score == null || lowest_score.score > leaderboard_score.score):
			lowest_score = leaderboard_score
	return lowest_score;

func get_last_leaderboard_player_name() -> String:
	return 	MetaProgression.save_data["leaderboard"]["leaderboard_last_player_name"]
	
# Function to generate the ID based on current date and time, and player name
func generate_player_id(player_name: String) -> String:
	player_name = player_name.strip_edges()

	var now = Time.get_datetime_dict_from_system()

	return player_name + str(now.year) + \
		str(now.month) + \
		str(now.day) + \
		str(now.second) + \
		str(now.minute) + \
		str(now.hour)

extends Node
@onready var timer: Timer = $Timer

const SAVE_FILE_PATH = "user://ratsbane.save"
# Using numbers since the default value is otherwise false
var won_recent_game = 0
var player_score:int = 0
var player_healed_this_run:bool = false
var player_lasted_time_in_seconds:int = 0
var amount_of_upgrades_picked:int = 0
var build_version = "v0.1.3.9"
var is_beta:bool = false
var currently_playing_on = ""
var was_player_on_full_health:bool 
var player_did_not_pick_own_cards_during_run = true
var continue_counting:bool = true
var total_time_spend_playing:int = 0
var time_elapsed = 0.0

# Default data for when we have no save data
var save_data: Dictionary = {
	"build_version": build_version,
	"is_beta": is_beta,
	"meta_upgrade_currency": 0, # Currency to buy upgrades
	"shop_currency":0, # Currency to buy skins and other stuff (gained from score)
	"meta_stats": {
		"total_games_played": 0,
		"total_playtime_in_seconds": 0,
		"total_wins": 0,
		"total_losses": 0,
		"total_rage_quits": 0,
		"map_stats": {},
		"last_player_score": 0,
		"best_player_score":0,
		"last_time_in_seconds": 0,
		"best_time_in_seconds": 0,
		"inventory_unlocked": false
	},
	"meta_upgrades": {},
	"achievements": {},
	"leaderboard": {
	"leaderboard_last_player_name": "",
	"leaderboard_scores": {
		"the_courtyard": {
			"ranking1": {
					"ranking_id":"ranking1",
					"id": "dallegambe20250725435015",
					"player_name": "Dalle Gambe",
					"score": 1000000,
					"date": "25-07-2025",
					"build_version": "v0.1.3.6",
					"time_played": "00:10:01",
				},
				"ranking2": {
					"ranking_id":"ranking2",
					"id": "ignithia20250626480812",
					"player_name": "Ignithia",
					"score": 750000,
					"date": "26-06-2025",
					"build_version": "v0.1.3.6",
					"time_played": "00:7:01",
				},
				"ranking3": {
					"ranking_id":"ranking3",
					"id": "robbe2025072480113",
					"player_name": "Robbe",
					"score": 500000,
					"date": "24-07-2025",
					"build_version": "v0.1.3.6",
					"time_played": "00:04:01",
				},
				"ranking4": {
					"ranking_id":"ranking4",
					"id": "yourmom20250718130717",
					"player_name": "Your Mom",
					"score": 250000,
					"date": "18-07-2025",
					"build_version": "v0.1.3.6",
					"time_played": "00:03:36",
				},
				"ranking5": {
					"ranking_id":"ranking5",
					"id": "drevile20250718130717",
					"player_name": "Drevile",
					"score": 100000,
					"date": "18-07-2025",
					"build_version": "v0.1.3.6",
					"time_played": "00:02:01",
				},
			}
		},	
	}
}

func _process(delta: float) -> void:
	if(continue_counting != false):
		time_elapsed += delta
		if time_elapsed >= 1.0:
			total_time_spend_playing += 1
			time_elapsed = 0.0  # Reset the timer
  
func _ready() -> void:
	GameEvents.experience_vial_collected.connect(on_experience_collected)
	load_save_file()
	check_and_update_to_latest_version()
	total_time_spend_playing = save_data["meta_stats"]["total_playtime_in_seconds"]
	resume_timer()

func _exit_tree() -> void:
	pause_timer()
	if "total_playtime_in_seconds" not in save_data["meta_stats"] or not save_data["meta_stats"]["total_playtime_in_seconds"]:
		save_data["meta_stats"]["total_playtime_in_seconds"] = 0
	save_data["meta_stats"]["total_playtime_in_seconds"] = total_time_spend_playing
	save()

# Called when the game window gains or loses focus
func _notification(application_status: int) -> void:
	if application_status == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		pause_timer()
	elif application_status == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		resume_timer()
		
# Pause the timer
func pause_timer() -> void:
	continue_counting = false

# Resume the timer
func resume_timer() -> void:
	continue_counting = true

func load_save_file() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		AchievementManager.update_achievements_in_save()
		create_maps()
		return
	var file = FileAccess.open(SAVE_FILE_PATH,FileAccess.READ)	
	# replace default data with whatever is in this file
	save_data = file.get_var()

func save() -> void:
	var file = FileAccess.open(SAVE_FILE_PATH,FileAccess.WRITE)	
	file.store_var(save_data)

func check_and_update_to_latest_version() -> void:
	#save_data["meta_upgrade_currency"] = 5000
	#AchievementManager.update_achievements_in_save()
	if(save_data["build_version"] != build_version):
		save_data["build_version"] = build_version
		#save_data["meta_upgrade_currency"] = 5000
		save_data["is_beta"] = is_beta	
		check_if_inventory_unlocked_exists()
		
		create_maps()
			
		AchievementManager.update_achievements_in_save()
		save()

func create_maps() -> void:
	# Ensure "map_stats" exists in "meta_stats"
	if "map_stats" not in save_data["meta_stats"]:
		save_data["meta_stats"]["map_stats"] = {}
	
	# Iterate over all maps
	for map: Map in MapManager.get_maps():
		# Initialize map data if it doesn't already exist
		if map.id not in save_data["meta_stats"]["map_stats"]:
			save_data["meta_stats"]["map_stats"][map.id] = {
				"total_games_played": 0,
				"total_time_spent_on_this_map": 0,
				"last_time_in_seconds": 0,
				"last_player_score": 0,
				"best_time_in_seconds": 0,
				"best_player_score": 0,
				"modifiers": {},
			}
		
		# Add modifiers for the map
		for modifier: Modifier in map.modifiers:
			add_modifier(modifier, map)

func check_if_inventory_unlocked_exists() -> void:
		if "inventory_unlocked" not in save_data["meta_stats"]:
			save_data["meta_stats"] = {
				"inventory_unlocked": get_all_owned_meta_upgrades_count() > 0,
			}
	
func add_meta_upgrade(upgrade: MetaUpgrade) -> void:
	# If there isn't an instance of the meta upgrade in question yet, add it to the list with quantity of 0
	if not save_data["meta_upgrades"].has(upgrade.id):
		save_data["meta_upgrades"][upgrade.id] = {
			"owned_quantity":0,
			"active_quantity":0,
			"max_quantity": upgrade.max_quantity,
			"is_currently_active": true
		}
	
	save_data["meta_upgrades"][upgrade.id]["owned_quantity"] += 1
	save_data["meta_upgrades"][upgrade.id]["active_quantity"] = save_data["meta_upgrades"][upgrade.id]["owned_quantity"]
	
	if(get_all_owned_meta_upgrades_count() > 0 and save_data["meta_stats"]["inventory_unlocked"] == false):
		save_data["meta_stats"]["inventory_unlocked"] = true
		GameEvents.emit_unlock_inventory(true)
	save()
	
func add_achievement(achievement:Achievement) -> void:
	if not save_data["achievements"].has(achievement.id):
		save_data["achievements"][achievement.id] = {
			"started_at": achievement.started_at,
			"completed_on": achievement.completed_on,
			"current_progress":0,
			"target_goal": achievement.target_goal,
			"category": achievement.category
		}
		save()	
	
func get_saved_modifier_data(modifier_id: String, map: Map) -> Dictionary:
	if save_data["meta_stats"].has("map_stats") and save_data["meta_stats"]["map_stats"].has(map.id):
		var map_data = save_data["meta_stats"]["map_stats"][map.id]
		
		# Check if the modifier exists for the map
		if map_data.has("modifiers") and map_data["modifiers"].has(modifier_id):
			return map_data["modifiers"][modifier_id]
	
	# If not found, check if the map has the modifier and add it
	if map.modifiers.has(modifier_id):
		add_modifier(map.modifiers[map.modifiers.find(modifier_id)], map)
		
		# Re-check if the modifier now exists after adding
		if save_data["meta_stats"]["map_stats"].has(map.id) and \
		   save_data["meta_stats"]["map_stats"][map.id]["modifiers"].has(modifier_id):
			return save_data["meta_stats"]["map_stats"][map.id]["modifiers"][modifier_id]
	
	# If no data found, return an empty dictionary
	print("Modifier not found, returning empty dictionary.")
	return {}
	
func add_modifier(modifier:Modifier, map:Map) -> void:
	if not save_data["meta_stats"]["map_stats"][map.id]["modifiers"].has(modifier.id) && map.modifiers.has(modifier):
		save_data["meta_stats"]["map_stats"][map.id]["modifiers"][modifier.id] = {
			"title": modifier.title,
			"description": modifier.description,
			"has_been_beaten": modifier.has_been_beaten,
			"is_unlocked": modifier.is_unlocked,
			"is_active": modifier.is_active
		}
	save()	

func update_modifier(modifier:Modifier, map:Map) -> void:
	if save_data["meta_stats"]["map_stats"][map.id]["modifiers"].has(modifier.id):
		save_data["meta_stats"]["map_stats"][map.id]["modifiers"][modifier.id] = {
			"title": modifier.title,
			"description": modifier.description,
			"has_been_beaten": modifier.has_been_beaten,
			"is_unlocked": modifier.is_unlocked,
			"is_active": modifier.is_active
		}
		save()	
	else:
		add_modifier(modifier, map)	

func set_achievement_progress(achievement_id:String, new_progress:int) -> void:
	var achievement = save_data["achievements"][achievement_id]
	achievement["current_progress"] = new_progress	
	if(achievement["started_at"] == "N/A"):
		var date = Time.get_datetime_string_from_system()
		achievement["started_at"] = date
	save()

func increase_rage_quits_by(number:int=1) -> void:
	save_data["meta_stats"]["total_rage_quits"] += number
	save()

func increase_games_played_by(number:int, playing_on_map:String) -> void:
	currently_playing_on = playing_on_map
	if "total_games_played" not in save_data or not save_data["total_games_played"]:
		save_data["total_games_played"] = number
	else:
		save_data["total_games_played"] += number
		
	#if "map_stats" not in save_data["meta_stats"] or not save_data["meta_stats"]:
		#save_data["meta_stats"] = {
			#"map_stats": {
			#playing_on_map: {
				#"total_games_played":number,
				#"last_time_in_seconds":0,
				#"last_player_score":0,
				#"best_time_in_seconds":0,
				#"best_player_score":0,	
				#"modifiers": {}
				#}
			#}
		#}
	#else:	
		save_data["meta_stats"]["map_stats"][playing_on_map]["total_games_played"] += number
	save()

func increase_meta_stats(won_battle: bool) -> void:
	if not save_data.has("meta_stats"):
		save_data["meta_stats"] = {}

	var meta_stats = save_data["meta_stats"]

	# Initialize total wins/losses if missing
	if not meta_stats.has("total_wins"):
		meta_stats["total_wins"] = 0
	if not meta_stats.has("total_losses"):
		meta_stats["total_losses"] = 0

	# Initialize map_stats if missing
	if not meta_stats.has("map_stats"):
		meta_stats["map_stats"] = {}

	var map_stats = meta_stats["map_stats"]

	# Initialize current map stats if missing
	if not map_stats.has(currently_playing_on):
		map_stats[currently_playing_on] = {
			"total_games_played": 0,
			"last_time_in_seconds": 0,
			"last_player_score": 0,
			"best_time_in_seconds": 0,
			"best_player_score": 0,
		}

	# Update win/loss stats
	if won_battle:
		meta_stats["total_wins"] += 1
		won_recent_game = 1  # Indicates a recent win
	else:
		meta_stats["total_losses"] += 1
		won_recent_game = 2  # Indicates a recent loss

	# Update general stats
	meta_stats["last_player_score"] = player_score
	meta_stats["last_time_in_seconds"] = player_lasted_time_in_seconds
	meta_stats["best_player_score"] = max(player_score, meta_stats.get("best_player_score", 0))
	meta_stats["best_time_in_seconds"] = max(player_lasted_time_in_seconds, meta_stats.get("best_time_in_seconds", 0))

	# Update map-specific stats
	var current_map_stats = map_stats[currently_playing_on]
	current_map_stats["total_games_played"] += 1
	current_map_stats["last_player_score"] = player_score
	current_map_stats["last_time_in_seconds"] = player_lasted_time_in_seconds
	current_map_stats["best_player_score"] = max(player_score, current_map_stats.get("best_player_score", 0))
	current_map_stats["best_time_in_seconds"] = max(player_lasted_time_in_seconds, current_map_stats.get("best_time_in_seconds", 0))
	
	for achievement_id in MetaProgression.get_achievements_from_category(Achievement.achievement_category.END_GAME):
		check_and_update_progress_of(achievement_id, Achievement.achievement_category.END_GAME)	
	save()
	print(save_data["meta_stats"])

func increase_achievement_progress_by(achievement_id:String, progress:int) -> void:
	var achievement = save_data["achievements"][achievement_id]
	achievement["current_progress"] += progress	
	if(achievement["started_at"] == "N/A"):
		var date = Time.get_datetime_string_from_system()
		achievement["started_at"] = date
	save()

func get_saved_achievement_data(achievement_id:String):
	return save_data["achievements"][achievement_id]

func get_achievements_from_category(category: Achievement.achievement_category) -> Array:
	var achievements = save_data["achievements"] as Dictionary
	var found_achievements = []
	for achievement_id in achievements.keys():
		var achievement_category = achievements[achievement_id]["category"]
		if(achievement_category == category):
			found_achievements.append(achievement_id)
	return found_achievements
	
func get_achievement_progress(achievement_id:String) -> int:
	if(MetaProgression.save_data["achievements"].has(achievement_id)):
		return save_data["achievements"][achievement_id]["current_progress"]
	else:
		return 0	

func get_achievement_target_goal(achievement_id:String) -> int:
	if(MetaProgression.save_data["achievements"].has(achievement_id)):
		return save_data["achievements"][achievement_id]["target_goal"]
	else:
		return 1

func get_all_owned_meta_upgrades_count() -> int:
	var owned_count = 0
	for meta_upgrade_id in save_data["meta_upgrades"].keys():
		var meta_upgrade = save_data["meta_upgrades"][meta_upgrade_id]
		if(meta_upgrade["owned_quantity"] > 0):
			owned_count+=1
	return owned_count
	
func get_meta_upgrade_count(meta_upgrade_id:String) -> int:
	if(MetaProgression.save_data["meta_upgrades"].has(meta_upgrade_id)):
		return save_data["meta_upgrades"][meta_upgrade_id]["owned_quantity"]
	else:
		return 0	

func get_active_meta_upgrade_count(meta_upgrade_id:String) -> int:
	if(MetaProgression.save_data["meta_upgrades"].has(meta_upgrade_id)):
		return save_data["meta_upgrades"][meta_upgrade_id]["active_quantity"]
	else:
		return 0	
	
func get_saved_leaderboard_scores(map_name: String = "") -> Array:
	var leaderboard_scores = save_data["leaderboard"]["leaderboard_scores"]
	if map_name == "":
		# Return all scores from all maps (flattened into one array)
		var all_scores = []
		for map_key in leaderboard_scores.keys():
			for ranking_key in leaderboard_scores[map_key].keys():
				all_scores.append(leaderboard_scores[map_key][ranking_key])
		return all_scores

	elif map_name == "general":
		# Return top 5 scores based on all maps combined, sorted by score descending
		var all_scores = []
		for map_key in leaderboard_scores.keys():
			for ranking_key in leaderboard_scores[map_key].keys():
				all_scores.append(leaderboard_scores[map_key][ranking_key])
		
		all_scores.sort_custom(compare_scores_desc)
		return all_scores.slice(0, 5)

	else:
		# Return scores for the specific map
		if map_name in leaderboard_scores:
			return leaderboard_scores[map_name].values()
		else:
			return []

# Custom sort function to sort by score descending
func compare_scores_desc(a, b) -> int:
	# Return -1 if a should come before b (higher score first), 1 if after, 0 if equal
	if a["score"] > b["score"]:
		return -1
	elif a["score"] < b["score"]:
		return 1
	else:
		return 0
		
func is_meta_upgrade_enabled(upgrade_id:String) -> bool:
	return get_active_meta_upgrade_count(upgrade_id) > 0 and save_data["meta_upgrades"][upgrade_id]["is_currently_active"] == true

func is_best_time(time_in_seconds:int) -> bool:
	return time_in_seconds > save_data["meta_stats"]["best_time_in_seconds"]

func is_best_score(new_player_score:float) -> bool:
	return new_player_score > save_data["meta_stats"]["best_player_score"]

func is_best_map_score(new_map_player_score:float) -> bool:
	return new_map_player_score > save_data["meta_stats"]["map_stats"][currently_playing_on]["best_player_score"]

func is_best_map_time(time_in_seconds:float) -> bool:
	return time_in_seconds > save_data["meta_stats"]["map_stats"][currently_playing_on]["best_time_in_seconds"]

func handle_payment(meta_upgrade:MetaUpgrade) -> void:
	save_data["meta_upgrade_currency"] -= meta_upgrade.experience_cost

func check_and_update_progress_of(achievement_id:String, category: Achievement.achievement_category) -> void:
	#print(achievement_id)
	if(MetaProgression.is_achievement_completed(achievement_id) == false):
		var progress = MetaProgression.get_achievement_progress(achievement_id)
		match category:
			# Case NONE SHOP, DURING_GAME, END_GAME}
			0:
				match achievement_id:
					"what_did_you_expect":
						progress = 1
					"why_just_why":
						progress = 1
			# Case Shop
			1:
				match achievement_id:
					"it_is_yours_my_friend":
						progress += 1
					"monopoly":
						var meta_upgrades_bought_higher_than_one = 0
						# Check the quantity of all meta upgrades and add 1 for each quantity that is bigger than 0
						for meta_upgrade_id in save_data["meta_upgrades"].keys():
							var meta_upgrade = save_data["meta_upgrades"][meta_upgrade_id]
							if(meta_upgrade["owned_quantity"] > 0):
								meta_upgrades_bought_higher_than_one += 1
						#print("Achievements higher: " + str(meta_upgrades_bought_higher_than_one))		
						progress = meta_upgrades_bought_higher_than_one
					"where_there_is_opportunity_i_will_be_there":
						# Check if any meta upgrade is equal to their max amount
						# If this is the case, complete the achievement
						for meta_upgrade_id in save_data["meta_upgrades"].keys():
							var meta_upgrade =  save_data["meta_upgrades"][meta_upgrade_id]
							var has_reached_max_quantity = meta_upgrade["owned_quantity"]  == meta_upgrade["max_quantity"] 
							if(has_reached_max_quantity == true):
								progress = 1
								break
					"i_will_take_your_entire_stock":
						var all_quantities = 0
						# Add all the quantities up together
						for meta_upgrade_id in save_data["meta_upgrades"].keys():
							var meta_upgrade =  save_data["meta_upgrades"][meta_upgrade_id]
							all_quantities += meta_upgrade["owned_quantity"]
						progress = 	all_quantities
					"_":
						progress = 0
			# Case Weapon
			2:
				pass			
			# Case End game
			3:
				match achievement_id:
					"early_retirement":
						if(save_data["meta_stats"]["total_losses"] == 1):
							progress = 1
					"i_should_have_retired":
						if(won_recent_game == 2):
							progress += 1	
					"im_a_pyschic":
						if(save_data["meta_stats"]["total_wins"] == 1):
							progress = 1
					"no_mercy":
						if(won_recent_game == 1):
							progress += 1		
					"explosive_potato":
						if(save_data["meta_stats"]["total_rage_quits"] == 1):
							progress = 1
					"flawless_victory":
						if(was_player_on_full_health and player_healed_this_run == false):
								progress = 1
					"the_classic":
						if(player_healed_this_run == false and won_recent_game == 1):	
							progress = 1	
					"survive_till_you_thrive":
						if(save_data["meta_stats"]["last_time_in_seconds"] >= 600):
							progress = 1	
					"fake_it_till_you_make_it":
						if(was_player_on_full_health and player_healed_this_run == true):	
							progress = 1
					"a_spirale_out_of_control":
						if(won_recent_game == 1):
							var new_progress = amount_of_upgrades_picked # get new progress
							if(new_progress > progress):
								progress = new_progress
					"who_needs_hands":
						var achievement_current_progress = get_achievement_progress("who_needs_hands")
						var achievement_target_goal = get_achievement_target_goal("who_needs_hands")
						progress = get_score_based_progress(achievement_current_progress, achievement_target_goal)		
					"size_does_not_matter":
						var achievement_current_progress = get_achievement_progress("size_does_not_matter")
						var achievement_target_goal = get_achievement_target_goal("size_does_not_matter")
						progress = get_score_based_progress(achievement_current_progress, achievement_target_goal)		
					"im_still_standing":
						var achievement_current_progress = get_achievement_progress("im_still_standing")
						var achievement_target_goal = get_achievement_target_goal("im_still_standing")
						progress = get_score_based_progress(achievement_current_progress, achievement_target_goal)	
					"persistent_legend":
						var achievement_current_progress = get_achievement_progress("persistent_legend")
						var achievement_target_goal = get_achievement_target_goal("persistent_legend")
						progress = get_score_based_progress(achievement_current_progress, achievement_target_goal)	
					"a_force_to_be_reckoned_with":
						var achievement_current_progress = get_achievement_progress("a_force_to_be_reckoned_with")
						var achievement_target_goal = get_achievement_target_goal("a_force_to_be_reckoned_with")
						progress = get_score_based_progress(achievement_current_progress, achievement_target_goal)
					"choices_are_hard":
						if(player_did_not_pick_own_cards_during_run == true and won_recent_game == 1):
							# If the value of the boolean is true => did_not_pick_own_cards and the player won the game
							progress = 1					
			_:
				print("HOW")	
		# If the progress has been updated, update the achievement progress		
		if(progress != 0):
			MetaProgression.set_achievement_progress(achievement_id, progress)
			if(MetaProgression.is_achievement_completed(achievement_id) == true):
				# if completed handle it 
				MetaProgression.handle_achievement_completion(achievement_id)
				# send notification
				var achievement = AchievementManager.get_achievement(achievement_id)
				NotificationOverlay.add_unlocked_achievement_to_queue(achievement)
				NotificationOverlay.handle_achievement_unlock()

func get_score_based_progress(current_progress:int, max_progress:int) -> int:
	var new_progress = player_score
	if(player_score > max_progress):
		new_progress = max_progress
	if(new_progress > current_progress):
		current_progress = new_progress	
	return current_progress	

func get_total_playtime() -> int:
	return total_time_spend_playing
		
func handle_achievement_completion(achievement_id: String) -> void:
	var achievement = get_saved_achievement_data(achievement_id)
	#print(achievement)
	if achievement["completed_on"] != "NNA":
		var date = Time.get_datetime_string_from_system()
		achievement["completed_on"] = date
		save()

func is_meta_upgade_sold_out(meta_upgrade:MetaUpgrade) -> bool:
	if(MetaProgression.save_data["meta_upgrades"].has(meta_upgrade.id)):
		return MetaProgression.save_data["meta_upgrades"][meta_upgrade.id]["owned_quantity"] == meta_upgrade.max_quantity
	else:
		return false	
		
func is_meta_upgrade_sold_out_integer(meta_upgrade:MetaUpgrade) -> int:
	if(MetaProgression.save_data["meta_upgrades"].has(meta_upgrade.id)):
		var is_sold_out = MetaProgression.save_data["meta_upgrades"][meta_upgrade.id]["owned_quantity"] == meta_upgrade.max_quantity
		if(is_sold_out == true):
			return 1
		else:
			return 0		
	else:
		return 0			

func is_achievement_completed(achievement_id:String) -> bool:
	if(MetaProgression.save_data["achievements"].has(achievement_id)):
		return MetaProgression.save_data["achievements"][achievement_id]["current_progress"] == MetaProgression.save_data["achievements"][achievement_id]["target_goal"]
	else:
		return false	

func is_achievement_completed_integer(achievement:Achievement) -> bool:
	if(MetaProgression.save_data["achievements"].has(achievement.id)):
		var is_completed = MetaProgression.save_data["achievements"][achievement.id]["current_progress"] == achievement.target_goal
		if(is_completed == true):
			return 1
		else:
			return 0		
	else:
		return 0		 

func on_experience_collected(amount_of_exp:float) -> void:
	save_data["meta_upgrade_currency"] += amount_of_exp

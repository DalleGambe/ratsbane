extends Node

@export var achievements: Array[Achievement]

func _ready() -> void:
	# Check if MetaProgression has all achievements
	if(MetaProgression.save_data["achievements"].keys().size() != achievements.size()):
		# Check if MetaProgression has achievement from achievements in save data
		for achievement in achievements:
			#  if they don't add them
			if not (MetaProgression.save_data["achievements"].keys().has(achievement.id)):
				MetaProgression.add_achievement(achievement)
				
func get_achievement(achievement_id:String) -> Achievement:
	# Get data from save file if it exists
	var saved_achievement_data = MetaProgression.get_saved_achievement_data(achievement_id)
	var achievement
	if(saved_achievement_data != null):
		# Get achievement from list
		var achievement_in_list = get_achievement_from_list(achievement_id)	
		# combine the two and return it
		achievement_in_list.current_progress = saved_achievement_data["current_progress"]
		achievement = achievement_in_list.duplicate()
	return achievement

func get_achievement_from_list(achievement_id:String) -> Achievement:
	for achievement in achievements:
		if(achievement.id) == achievement_id:
			return achievement
	return null		

func update_achievements_in_save() -> void:
	# Reference to the achievements in the save data
	var saved_achievements = MetaProgression.save_data["achievements"]

	# Iterate over the currently loaded achievements
	for achievement in achievements:
		var id = achievement.id
		if saved_achievements.has(id):
			# Achievement exists in save, update target goal and current progress
			var saved_data = saved_achievements[id]
			if(achievement.target_goal_is_dynamic == true):
				# logic to test if values are up to date
				saved_data["target_goal"] = get_dynamic_value(achievement)
			else:	
				saved_data["target_goal"] = achievement.target_goal
								
			# Adjust current_progress if the target_goal has decreased
			if saved_data["current_progress"] > achievement.target_goal:
				saved_data["current_progress"] = achievement.target_goal
		else:
			if(achievement.target_goal_is_dynamic == true):
				achievement.target_goal = get_dynamic_value(achievement)
				# Add new achievement to save
				saved_achievements[id] = {
					"started_at": achievement.started_at,
					"completed_on": achievement.completed_on,
					"current_progress": achievement.current_progress,
					"target_goal": achievement.target_goal,
					"category": achievement.category
				}

	# Remove achievements from the save file that are no longer in the loaded list
	var loaded_ids = []
	for achievement in achievements:
		loaded_ids.append(achievement.id)

	for saved_id in saved_achievements.keys():
		if not loaded_ids.has(saved_id):
			saved_achievements.erase(saved_id)
			
func get_dynamic_value(achievement:Achievement) -> int:
	var dynamic_value:int = 0
	# Case NONE = 0, SHOP = 1, WEAPON = 2, END_GAME = 3
	match achievement.category:
		# NONE
		0:
			match achievement.id:
				pass
		# SHOP		
		1:
			match achievement.id:
				# Count Every Meta Upgrade
				"monopoly":
					dynamic_value = MetaUpgradeManager.meta_upgrades.size()
				# Count all quantities of every meta upgrade	
				"i_will_take_your_entire_stock":
					dynamic_value = MetaUpgradeManager.get_all_meta_upgrade_max_quantity()
		# Weapon			
		2:
			match achievement.id:
				pass
		# End Game		
		3:
			match achievement.id:
				# Count all quantities of level upgrades
				"a_spirale_out_of_control":
					print("SPIRALE IS NOW 34")
					dynamic_value = 34			
	return dynamic_value			

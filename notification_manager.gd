extends Node

signal achievement_unlocked(achievement:Achievement)
signal handle_achievement

func emit_achievement_unlocked(achievement:Achievement) -> void:
	print("unlocked an achievement")
	achievement_unlocked.emit(achievement)
	
func emit_handle_achievement() -> void:
	print("handling the achievement")
	handle_achievement.emit()	
	

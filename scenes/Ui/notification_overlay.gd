extends CanvasLayer

@onready var achievement_unlocked_card: PanelContainer = %AchievementUnlockedCard
signal achievement_notification_done
var achievements_unlocked: Array[Achievement] = []
var is_notification_active: bool = false  # Prevent multiple notifications from overlapping

func _ready() -> void:
	NotificationManager.achievement_unlocked.connect(add_unlocked_achievement_to_queue)
	NotificationManager.handle_achievement.connect(handle_achievement_unlock)

# Loops through the queue of achievements being unlocked and displays them one by one
func handle_achievement_unlock() -> void:
	if is_notification_active:
		return  # Exit if another notification is already active

	is_notification_active = true
	while achievements_unlocked.size() > 0:
		var achievement = achievements_unlocked[0]  # Take the first achievement in the queue
		#print("Displaying achievement: " + achievement.id)
		set_achievement_unlocked_notification(achievement)
		await show_achievement_unlocked_notification()  # Wait until notification completes
		#print("Notification complete. Removing achievement: " + achievement.id)
		remove_unlocked_achievement_from_queue(achievement)
	is_notification_active = false
	#print("All queued achievements have been processed.")

# Sets the current information for the notification
func set_achievement_unlocked_notification(achievement: Achievement) -> void:
	#print("Setting notification content for achievement: " + achievement.id)
	achievement_unlocked_card._set_achievement(achievement)

# Adds the achievement to the queue
func add_unlocked_achievement_to_queue(achievement: Achievement) -> void:
	#print("Processing achievement unlock: " + achievement.id)
	if not achievements_unlocked.has(achievement):  # Avoid duplicates
		#print("Adding achievement to queue: " + achievement.id)
		achievements_unlocked.append(achievement)
	#else:
		#print("Achievement already in queue: " + achievement.id)

# Removes the achievement from the queue
func remove_unlocked_achievement_from_queue(achievement: Achievement) -> void:
	achievements_unlocked.erase(achievement)

# Shows the current active achievement that has been unlocked
func show_achievement_unlocked_notification() -> void:
	achievement_unlocked_card.show()
	achievement_unlocked_card.play_enter_animation()
	await get_tree().create_timer(1.5).timeout  # Wait for "enter" animation
	achievement_unlocked_card.play_animation("flip_card")
	await get_tree().create_timer(1.5).timeout  # Wait for "flip card" animation
	achievement_unlocked_card.play_animation("leave_screen")
	await get_tree().create_timer(0.5).timeout  # Small buffer to ensure animations are complete
	achievement_notification_done.emit()
	#print("Notification animations finished.")

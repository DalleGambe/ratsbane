extends Node
class_name ExperienceManager

const TARGET_EXPERIENCE_GROWTH = 5.0

@onready var sfx_collect_reset: Timer = $SfxCollectReset

# The current amount of experience
var current_experience = 0.0
# The current level
var current_level = 1.0
var amount_of_experience_recently_collected = 0
var max_level = 999.0
# The amount of experience required to level up
var target_experience = 2.0

# Track whether the experience handling process is ongoing
var is_handling_experience = false

signal experience_updated(current_experience: float, target_experience: float)
signal level_up(new_level: int)
signal all_upgrades_handled()

func _ready() -> void:
	GameEvents.experience_vial_collected.connect(on_experience_vial_collected)
	sfx_collect_reset.timeout.connect(on_sfx_collect_reset_timeout)

func increment_experience(amount_of_new_experience: float) -> void:
	if is_handling_experience:
		return  # Prevent overlapping calls
	
	is_handling_experience = true
	
	var pending_levels:int = 0
	# Only process experience if the player is not at the max level
	while amount_of_new_experience > 0 and not is_max_level(current_level):
		var remaining_experience = target_experience - current_experience
		if amount_of_new_experience >= remaining_experience:
			# Add enough to level up
			current_experience += remaining_experience
			amount_of_new_experience -= remaining_experience
			# Level up
			current_level += 1
			pending_levels += 1
			current_experience = 0
			# Increase the boundary
			target_experience += TARGET_EXPERIENCE_GROWTH
			# Emit signals
			experience_updated.emit(current_experience, target_experience)
		else:
			# Add remaining experience without leveling up
			current_experience += amount_of_new_experience
			amount_of_new_experience = 0
	
	# Emit updated experience
	experience_updated.emit(current_experience, target_experience)
	
	if(pending_levels > 0):
		#print("Amount of choices to make: " + str(pending_levels))
		level_up.emit(pending_levels)
		# Pause to let the player handle the upgrade menu
		await get_tree().create_timer(0.1).timeout	
	
	pending_levels = 0
	is_handling_experience = false
	all_upgrades_handled.emit()

func is_max_level(current_level: float) -> bool:
	return current_level >= max_level

func on_experience_vial_collected(amount_of_experience: float) -> void:
	increment_experience(amount_of_experience)

func on_sfx_collect_reset_timeout() -> void:
	amount_of_experience_recently_collected = 0

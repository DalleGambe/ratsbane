extends Node

class_name ArenaStatsManager

var healing_cooldown:int = 0
var times_do_nothing_button_was_pressed_this_run:int = 0
var times_do_nothing_button_was_pressed_this_run_consecutively:int = 0
var amount_of_player_heals_this_run:int = 0
	
func set_healing_cooldown(new_cooldown_value:int) -> void:
	healing_cooldown = new_cooldown_value

func add_to_player_healing_count(increment_value:int) -> void:
	amount_of_player_heals_this_run += 1
	MetaProgression.player_healed_this_run = true

func increment_do_nothing_button_pressed_count_by(increment_value:int) -> void:
	times_do_nothing_button_was_pressed_this_run += 1
	times_do_nothing_button_was_pressed_this_run_consecutively += 1
	if(times_do_nothing_button_was_pressed_this_run == 1):
		MetaProgression.check_and_update_progress_of("what_did_you_expect", Achievement.achievement_category.NONE)
	if(times_do_nothing_button_was_pressed_this_run_consecutively == 3):
		MetaProgression.check_and_update_progress_of("why_just_why", Achievement.achievement_category.NONE)

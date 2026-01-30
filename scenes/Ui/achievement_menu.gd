extends CanvasLayer

@export var achievements: Array[Achievement]

@onready var grid_container: GridContainer = %GridContainer
@onready var base_min_pitch:float = 1
@onready var base_max_pitch:float = 1

var achievement_card_scene = preload("res://scenes/Ui/achievement_card.tscn")

# Code with achievements auto popping
func _ready() -> void:
	achievements = AchievementManager.achievements
	# Remove the test cards
	for child in grid_container.get_children():
		child.queue_free()
	
	#var enter_delay = 0
	%BackButton.pressed.connect(on_back_button_pressed)
	%LeaderboardButton.pressed.connect(on_leaderboard_button_pressed)
	achievements.sort()
	achievements.sort_custom(func(achievement_a, achievement_b): return MetaProgression.is_achievement_completed_integer(achievement_a) < MetaProgression.is_achievement_completed_integer(achievement_b))
	#var pitch_to_add:float = 0
	#var currently_at_card:int = 1
	#var speed_scale:float = 1.0
	for achievement in achievements:
		MetaProgression.add_achievement(achievement)
		var achievement_card_instance = achievement_card_scene.instantiate()
		achievement_card_instance.custom_minimum_size.x = 600
		grid_container.add_child(achievement_card_instance)
		achievement_card_instance._set_achievement(achievement)
		#achievement_card_instance.audio_player.set_pitch(base_min_pitch+pitch_to_add, base_max_pitch+pitch_to_add)
		#achievement_card_instance.play_enter_animation(enter_delay)
		#enter_delay += 0.4
		#if(currently_at_card % 2 == 0):
			#pitch_to_add += 0.1
		#if(currently_at_card % 8 == 0):
			#speed_scale += 1	
		#currently_at_card += 1

# Code with looking and scrolling
#func _ready() -> void:
	#achievements = AchievementManager.achievements
	## Remove the test cards
	#for child in grid_container.get_children():
		#child.queue_free()
	#
	#var enter_delay = 0
	#%BackButton.pressed.connect(on_back_button_pressed)
	#achievements.sort_custom(func(achievement_a, achievement_b): return MetaProgression.is_achievement_completed_integer(achievement_a) < MetaProgression.is_achievement_completed_integer(achievement_b))
	#var pitch_to_add:float = 0
	#var currently_at_card:int = 1
	#var speed_scale:float = 1.0
	#for achievement in achievements:
		#MetaProgression.add_achievement(achievement)
		#var achievement_card_instance = achievement_card_scene.instantiate()
		#achievement_card_instance.custom_minimum_size.x = 600
		#grid_container.add_child(achievement_card_instance)
		#achievement_card_instance._set_achievement(achievement)
		#achievement_card_instance.audio_player.set_pitch(base_min_pitch+pitch_to_add, base_max_pitch+pitch_to_add)
		##achievement_card_instance.play_enter_animation(enter_delay)
		#if(currently_at_card == 1):
			#achievement_card_instance.enter_delay = 0
		#elif(currently_at_card == 3):
			#achievement_card_instance.enter_delay = 0.8
		#else:
			#achievement_card_instance.enter_delay = 0.4		
		#if(currently_at_card % 2 == 0):
			#pitch_to_add += 0.1
		#if(currently_at_card % 8 == 0):
			#speed_scale += 1	
		#currently_at_card += 1
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		on_back_button_pressed()

func on_back_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/Ui/MainMenu.tscn")	

func on_leaderboard_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	get_tree().change_scene_to_file("res://scenes/Ui/LeaderboardMenu.tscn")	

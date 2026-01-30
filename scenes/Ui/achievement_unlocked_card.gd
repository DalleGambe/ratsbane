extends PanelContainer

@onready var achievement_name_label:Label = %AchievementNameLabel
@onready var achievement_image: TextureRect = %AchievementImage
@onready var image_panel_container: PanelContainer = %ImagePanelContainer
@onready var title_panel_container: PanelContainer = %TitlePanelContainer
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var progress_label: Label = %ProgressLabel
@onready var animation_player: AnimationPlayer = %AnimationPlayer


var achievement: Achievement
var achievement_incomplete_texture = preload("res://scenes/Textures/panel_container_texture.tres")
var achievement_completed_texture = preload("res://scenes/Textures/panel_container_texture_gold.tres")

var card_is_disabled = false
var is_card_loading = false
var showing_card_back = false
	
func _set_achievement(_achievement: Achievement) -> void:
	achievement = _achievement
	achievement_name_label.text = achievement.title
	achievement_image.texture = achievement.image
	var current_progress = 0
	if MetaProgression.save_data["achievements"].has(achievement.id):
		current_progress = MetaProgression.save_data["achievements"][achievement.id]["current_progress"]
	var target_goal = MetaProgression.save_data["achievements"][achievement.id]["target_goal"]
	#var is_achievement_completed = MetaProgression.is_achievement_completed(achievement.id) //TODO: Used for rewards later
	var progress_percentage = current_progress / target_goal
	progress_percentage = min(progress_percentage, 1)
	progress_bar.value = progress_percentage
	progress_label.text = str(current_progress) + "/" + str(target_goal)
	
func play_enter_animation(delay:float = 0) -> void:
	modulate = Color.TRANSPARENT
	await get_tree().create_timer(delay).timeout
	%AnimationPlayer.play("enter_screen")
	
func play_animation(name_animation:String, delay:float = 0) -> void:
	await get_tree().create_timer(delay).timeout
	%AnimationPlayer.play(name_animation)
	
func set_is_being_loading(is_loading:bool) -> void:
		is_card_loading = is_loading

func change_completion_color_to(gold:bool) -> void:
	if(gold == true):
		title_panel_container.add_theme_stylebox_override("panel",achievement_completed_texture)
		image_panel_container.add_theme_stylebox_override("panel",achievement_completed_texture)
		add_theme_stylebox_override("panel",achievement_completed_texture)
	else:
		title_panel_container.add_theme_stylebox_override("panel",achievement_incomplete_texture)
		image_panel_container.add_theme_stylebox_override("panel",achievement_incomplete_texture)
		add_theme_stylebox_override("panel",achievement_incomplete_texture)	
	

extends PanelContainer

@onready var name_label:Label = %NameLabel
@onready var description_label:Label = %"Description Label"
@onready var progress_label: Label = %ProgressLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var started_on_label: Label = %StartedOnLabel
@onready var completed_on_label: Label = %CompletedOnLabel
@onready var achievement_image: TextureRect = %AchievementImage
@onready var image_panel_container: PanelContainer = %ImagePanelContainer
@onready var title_panel_container: PanelContainer = $MarginContainer/FrontOfCard/VBoxContainer/TitlePanelContainer
@onready var audio_player: RandomSteamPlayerComponent = %AudioPlayerComponent
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var achievement: Achievement
var achievement_completed_texture = preload("res://scenes/Textures/panel_container_texture_gold.tres")

var card_is_disabled = false
var is_card_loading = false
var showing_card_back = false
var has_played_enter_animation = false
var enter_delay = 0

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	visible_on_screen_notifier_2d.screen_entered.connect(on_screen_entered)
	
func _set_achievement(_achievement: Achievement) -> void:
	achievement = _achievement
	name_label.text = achievement.title
	description_label.text = achievement.description
	achievement_image.texture = achievement.image
	if MetaProgression.save_data["achievements"].has(achievement.id):
		# Get values stored in safe file
		started_on_label.text = tr("STARTED_ON_LABEL") + ": " + MetaProgression.save_data["achievements"][achievement.id]["started_at"]
		completed_on_label.text = tr("COMPLETED_AT_LABEL") + ": " + MetaProgression.save_data["achievements"][achievement.id]["completed_on"]	
	else:
		# Get default values
		started_on_label.text = tr("STARTED_ON_LABEL") + ": " + achievement.started_at
		completed_on_label.text = tr("COMPLETED_AT_LABEL") + ": " + achievement.completed_on
	update_progress()

func play_enter_animation(delay:float = 0) -> void:
	modulate = Color.TRANSPARENT
	await get_tree().create_timer(delay).timeout
	%AnimationPlayer.play("enter_screen")

func on_screen_entered() -> void:
	pass
	#if not has_played_enter_animation:
		#play_enter_animation(enter_delay)
		#has_played_enter_animation = true
	
func update_progress() -> void:
	var current_progress = 0
	if MetaProgression.save_data["achievements"].has(achievement.id):
		current_progress = MetaProgression.get_achievement_progress(achievement.id)
	var target_goal = MetaProgression.save_data["achievements"][achievement.id]["target_goal"]
	var is_achievement_completed = MetaProgression.is_achievement_completed(achievement.id)
	#print("current_progress: " + str(current_progress))
	#print("target_goal: " + str(target_goal))
	var progress_percentage:float = min(float(current_progress) / float(target_goal), 1)
	#print("Progress percentage: " + str(progress_percentage))
	progress_bar.value = progress_percentage
	progress_label.text = str(current_progress) + "/" + str(target_goal)
	if(is_achievement_completed == true):
		title_panel_container.add_theme_stylebox_override("panel",achievement_completed_texture)
		image_panel_container.add_theme_stylebox_override("panel",achievement_completed_texture)
		add_theme_stylebox_override("panel",achievement_completed_texture)

func set_is_being_loading(is_loading:bool) -> void:
		is_card_loading = is_loading

func _on_gui_input(event: InputEvent) -> void:
	if(event.is_action_pressed("left_click") and is_card_loading != true):
		# Change to other side of card
		showing_card_back = !showing_card_back
		is_card_loading = true
		%AnimationPlayer.play("flip_card")
		await %AnimationPlayer.animation_finished
		is_card_loading = false

func play_flip_audio() -> void:
	if(showing_card_back == true):
		%AudioPlayerComponent.play_random_audio("flip_card_to_back")
	else:
		%AudioPlayerComponent.play_random_audio("flip_card_to_front")

func change_card_side() -> void:
	var is_back_of_card = showing_card_back
	if(is_back_of_card == true):
		%FrontOfCard.hide()
		%BackOfCard.show()
	else:
		%FrontOfCard.show()
		%BackOfCard.hide()
	

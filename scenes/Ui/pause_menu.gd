extends CanvasLayer

@onready var main_panel_container: PanelContainer = %MainPanelContainer
@onready var continue_button: Button = %ContinueButton
@onready var restart_button: Button = %RestartButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton

var is_closing:bool
var options_menu_scene = preload("res://scenes/Ui/OptionsMenu.tscn")

func _ready() -> void:
	MenuManager._add_menu_to_list(self)
	main_panel_container.pivot_offset = main_panel_container.size / 2
	
	continue_button.pressed.connect(on_continue_button_pressed)
	restart_button.pressed.connect(on_restart_button_pressed)
	options_button.pressed.connect(on_options_button_pressed)
	quit_button.pressed.connect(on_quit_button_pressed)
	
	var tween = create_tween()
	tween.tween_property(main_panel_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(main_panel_container, "scale", Vector2.ONE, 0.3)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_BACK)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		close(false)
		get_tree().root.set_input_as_handled()

func close(restart:bool) -> void:
	if is_closing:
		return
		
	is_closing = true
	MenuManager._remove_menu_from_list(self)
	var blur_shader = get_tree().get_first_node_in_group("blurshader")
	blur_shader.queue_free()
	
	if(restart == true):
		ScreenTransition.transition()
		await ScreenTransition.transitioned_halfway
		get_tree().change_scene_to_file("res://scenes/Main/main.tscn")
	else:
		var tween = create_tween()
		tween.tween_property(main_panel_container, "scale", Vector2.ONE, 0)
		tween.tween_property(main_panel_container, "scale", Vector2.ZERO, 0.3)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_BACK)
		
		await tween.finished
	MusicPlayer.volume_db += 5	
	# Let sound of button finish playing
	queue_free()

func _exit_tree():
	MenuManager._remove_menu_from_list(self)
	
func on_continue_button_pressed() -> void:
	close(false)
	
func on_restart_button_pressed() -> void:
	close(true)

func on_options_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	var options_menu_instance = options_menu_scene.instantiate()
	MenuManager._add_menu_to_list(options_menu_instance)
	add_child(options_menu_instance)
	options_menu_instance.pressed_back_button.connect(on_options_back_button_pressed.bind(options_menu_instance))
	
func on_quit_button_pressed() -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	MetaProgression.save()
	MenuManager._remove_menu_from_list(self)
	get_tree().paused = false
	if(get_tree().get_first_node_in_group("player") == null):
		# Update potato achievement
		MetaProgression.increase_rage_quits_by(1)
		MetaProgression.check_and_update_progress_of("explosive_potato", Achievement.achievement_category.END_GAME)
		MetaProgression.save()
	get_tree().change_scene_to_file("res://scenes/Ui/MainMenu.tscn")		

func on_options_back_button_pressed(options_menu: Node) -> void:
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	options_menu.queue_free()

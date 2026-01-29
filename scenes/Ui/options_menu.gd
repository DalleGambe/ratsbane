extends CanvasLayer

var window_mode = SettingsManager.get_window_mode()
var config = ConfigFile.new()

signal pressed_back_button

@onready var window_mode_button: Button = %WindowModeButton
@onready var music_volume_slider: HSlider = %MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = %SFXVolumeSlider
@onready var back_button: Button = %BackButton
@onready var resolution_option_button: OptionButton = %ResolutionOptionButton
@onready var sfx_sound_player_component: RandomSteamPlayerComponent = $SfxSoundPlayerComponent
@onready var show_dmg_number_check_button: CheckButton = %ShowDmgNumberCheckButton
@onready var language_option_button: OptionButton = %LanguageOptionButton
@onready var sfx_percentage_label: Label = %SFXPercentageLabel
@onready var music_percentage_label: Label = %MusicPercentageLabel

var is_show_dmg_number_checked:bool

func _ready() -> void:
	# Connections
	window_mode_button.pressed.connect(on_window_button_pressed)
	back_button.pressed.connect(on_back_button_pressed)
	music_volume_slider.value_changed.connect(_on_music_volume_value_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_value_changed)
	resolution_option_button.item_selected.connect(on_resolution_item_selected)
	language_option_button.item_selected.connect(on_language_item_selected)
	show_dmg_number_check_button.pressed.connect(on_show_dmg_number_checkbutton_pressed)
	# Set initial values
	music_volume_slider.value = SettingsManager.get_music_volume()
	sfx_volume_slider.value = SettingsManager.get_sfx_volume()
	music_percentage_label.text = str(music_volume_slider.value*100) + "%"
	sfx_percentage_label.text = str(sfx_volume_slider.value*100) + "%"
	is_show_dmg_number_checked = SettingsManager.get_damage_number_setting()
	show_dmg_number_check_button.button_pressed = is_show_dmg_number_checked
	
	update_window_mode_display()
	add_resolutions_to_resolution_option_button()
	add_languages_to_language_option_button()
	update_resolution_button_values()
	set_selected_language_in_language_option_button()
	
func update_window_mode_display() -> void:
	window_mode_button.text = "Windowed"
	if window_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		window_mode_button.text = "Fullscreen"
	else:
		var resolution = SettingsManager.get_selected_resolution()
		SettingsManager.set_window_size(SettingsManager.resolution_vector_to_string(resolution))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		on_back_button_pressed()
		get_tree().root.set_input_as_handled()

func _save_settings() -> void:
	SettingsManager.set_audio_settings(round(music_volume_slider.value*100)/100, round(sfx_volume_slider.value*100)/100)
	SettingsManager.set_screen_settings(window_mode, SettingsManager.get_selected_resolution())
	SettingsManager.set_graphic_settings(is_show_dmg_number_checked)
	SettingsManager.save_settings()

# Adding resolutions from the manually defined list (in ScreenSettingsManager)
func add_resolutions_to_resolution_option_button() -> void:
	for key in SettingsManager.resolutions.keys():
		resolution_option_button.add_item(key)

func add_languages_to_language_option_button() -> void:
	for language in SettingsManager.languages.values():
		language_option_button.add_item(language)

func update_resolution_button_values() -> void:
	var window_size:Vector2i = SettingsManager.get_selected_resolution()
	var window_size_string = str(window_size.x) + "x" + str(window_size.y)
	
	# Set the currently selected resolution in the OptionButton
	for i in range(resolution_option_button.get_item_count()):
		if resolution_option_button.get_item_text(i) == window_size_string:
			resolution_option_button.select(i)
			break

func set_selected_language_in_language_option_button() -> void:
		var selected_language = SettingsManager.languages.get(SettingsManager.get_displayed_language_code())
		# Set the currently selected language in the OptionButton
		for i in range(language_option_button.get_item_count()):
			if language_option_button.get_item_text(i) == selected_language:
				language_option_button.select(i)
				break

func _on_music_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(SettingsManager.music_slider_index, linear_to_db(value))
	music_percentage_label.text = str(round(music_volume_slider.value * 100)) + "%"  # Round to nearest whole number

func _on_sfx_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(SettingsManager.sfx_slider_index, linear_to_db(value))	
	sfx_percentage_label.text = str(round(sfx_volume_slider.value * 100)) + "%"  # Round to nearest whole number

func on_window_button_pressed() -> void:
	window_mode = DisplayServer.window_get_mode()
	if window_mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	
	window_mode = DisplayServer.window_get_mode()
	update_window_mode_display()
	
func on_back_button_pressed() -> void:
	_save_settings()
	MenuManager._remove_menu_from_list(self)
	pressed_back_button.emit()

func on_resolution_item_selected(index:int) -> void:
	sfx_sound_player_component.play_requested_track_by_index(index)
	#print("Index being used: " + str(index))
	var resolution_key:String = resolution_option_button.get_item_text(index)
	#print("Resolution key from item text: " + str(resolution_key))
	SettingsManager.set_window_size(resolution_key)
	
func on_show_dmg_number_checkbutton_pressed() -> void:
	is_show_dmg_number_checked = !is_show_dmg_number_checked	
	
func on_language_item_selected(index:int) -> void:
	sfx_sound_player_component.play_requested_track_by_index(index)
	var language_key:String = SettingsManager.languages.keys()[index]
	SettingsManager.set_displayed_language(language_key)

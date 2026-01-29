extends Node

const SETTINGS_SAVE_FILE_PATH = "user://ratsbane_settings.save"

@onready var music_slider_index = AudioServer.get_bus_index("Music")
@onready var sfx_slider_index = AudioServer.get_bus_index("Sfx")
#@onready var keybind_resource : PlayerKeybindResource

var base_music_value = 0.75
var base_sfx_value = 0.75

# Default data for when we have no save data
var save_settings_data: Dictionary = {
	"audio": {},
	"screen": {},
	"graphics": {},
	"accessibility": {}
	#"keybinds": {}
}

var resolutions:Dictionary = {
	"3840x2160": Vector2i(3840,2160),
	"2560x1440": Vector2i(2568,1440), 
	"1920x1080": Vector2i(1920,1080),
	"1680x900": Vector2i(1680,900), 
	"1440x900": Vector2i(1440,900),
	"1366x768": Vector2i(1366,768),
	"1280x720": Vector2i(1280,720),
	"1024x600": Vector2i(1024,600),
	"800x600": Vector2i(800,600)
}

var languages:Dictionary = {
	"en": "ENGLISH_LANGUAGE",
	"nl": "DUTCH_LANGUAGE",	
} 

func _ready() -> void:
	load_save_file()

#func create_keybinds_dictionary() -> Dictionary:
	#var keybinds_dictionary = {
		#keybind_resource.MOVE_LEFT : keybind_resource.move_left_key,
		#keybind_resource.MOVE_RIGHT : keybind_resource.move_right_key,
		#keybind_resource.MOVE_UP : keybind_resource.move_up_key,
		#keybind_resource.MOVE_DOWN : keybind_resource.move_down_key,
		#keybind_resource.PAUSE_GAME : keybind_resource.pause_game_key
	#}
	#return keybinds_dictionary

func load_save_file() -> void:
	if not FileAccess.file_exists(SETTINGS_SAVE_FILE_PATH):
		print("SAVE file NOT FOUND")
		set_audio_settings(base_music_value,base_sfx_value)
		set_screen_settings()
		set_graphic_settings(true)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		set_displayed_language("en")
		#set_keybind_settings()
		save_settings()
		return
	var file = FileAccess.open(SETTINGS_SAVE_FILE_PATH,FileAccess.READ)	
	# replace default data with whatever is in this file
	save_settings_data = file.get_var()
	var selected_window_mode = get_window_mode()
	var selected_resolution = get_selected_resolution()
	set_bus_volume(get_music_volume(), get_sfx_volume())
	DisplayServer.window_set_mode(selected_window_mode)
	set_screen_settings(selected_window_mode,selected_resolution)
	TranslationServer.set_locale(get_displayed_language_code())
	
	if(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED):
		set_window_size(resolution_vector_to_string(selected_resolution))
	
func save_settings() -> void:
	var file = FileAccess.open(SETTINGS_SAVE_FILE_PATH,FileAccess.WRITE)	
	print(save_settings_data)
	file.store_var(save_settings_data)

func get_music_volume() -> float:
	return save_settings_data["audio"]["music_volume"]
	
func get_graphic_setting(name_of_setting:String):
	return save_settings_data["graphics"][name_of_setting]	

func get_damage_number_setting() -> bool:
	var show_damage_numbers = get_graphic_setting("show_damage_numbers")
	if(show_damage_numbers != null):
		return show_damage_numbers
	return true	
	
func get_sfx_volume() -> float:
	return  save_settings_data["audio"]["sfx_volume"]

func get_displayed_language_code() -> String:
	return save_settings_data["accessibility"]["displayed_language"]

func get_window_mode() -> int:
	return save_settings_data["screen"]["window_mode"]

func get_selected_resolution():
	return Vector2i(save_settings_data["screen"]["window_width"],save_settings_data["screen"]["window_height"])

func center_window() -> void:
	var screen_center = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(screen_center - window_size/2)

func set_audio_settings(new_music_volume:float = AudioServer.get_bus_volume_db(music_slider_index), new_sfx_volume:float = AudioServer.get_bus_volume_db(sfx_slider_index)) -> void:
	save_settings_data["audio"] = {
		"music_volume" = new_music_volume,
		"sfx_volume" = new_sfx_volume	
	}
	set_bus_volume(new_music_volume, new_sfx_volume)

func set_displayed_language(language_code:String) -> void:
		save_settings_data["accessibility"] = {
		"displayed_language" = language_code,
	}
		TranslationServer.set_locale(language_code)

func set_graphic_settings(show_damage_numbers:bool) -> void:
		save_settings_data["graphics"] = {
		"show_damage_numbers" = show_damage_numbers,
	}
	
#func set_keybind(action: String, event) -> void:
	#match action:
		#keybind_resource.MOVE_LEFT:
			#keybind_resource.move_left_key = event
		#keybind_resource.MOVE_RIGHT:
			#keybind_resource.move_right_key = event
		#keybind_resource.MOVE_UP:
			#keybind_resource.move_up_key = event
		#keybind_resource.MOVE_DOWN:
			#keybind_resource.move_down_key = event
		#keybind_resource.PAUSE_GAME:
			#keybind_resource.pause_game_key = event
			
func set_bus_volume(music_volume:float, sfx_volume:float) -> void:
	AudioServer.set_bus_volume_db(music_slider_index, linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(sfx_slider_index, linear_to_db(sfx_volume))

func check_if_current_device_screen_size_is_in_list() -> void:
	# Get size of the device screen
	var device_screen_size = DisplayServer.screen_get_size()
	# Convert screen size to string format (e.g., "1920x1080")
	var device_screen_size_string = resolution_vector_to_string(device_screen_size)

	# Check if the screen size is already in the resolutions dictionary
	if not resolutions.has(device_screen_size_string):
		resolutions[device_screen_size_string] = device_screen_size
		print("Added device screen resolution: ", device_screen_size_string)
	else:
		print("Device screen resolution already in the list: ", device_screen_size_string)

func update_resolution_list() -> void:
	# Get size of the computer screen
	var device_screen_size = DisplayServer.screen_get_size()
	# Create a new dictionary to store supported resolutions
	var supported_resolutions: Dictionary = {}
	
	# Loop through available resolutions
	for resolution_key in resolutions.keys():
		var resolution = resolutions[resolution_key]
		
		# Check if the resolution fits the current screen size
		if resolution.x <= device_screen_size.x and resolution.y <= device_screen_size.y:
			supported_resolutions[resolution_key] = resolution
		else:
			print("Resolution not supported on current screen: ", resolution_key)
	
	# Replace the original resolutions list with the supported ones
	resolutions = supported_resolutions

func check_if_selected_resolution_is_supported(selected_resolution:Vector2i) -> Vector2i:
	if not resolutions.has(resolution_vector_to_string(selected_resolution)):
		var fallback_resolution: Vector2i = resolutions.values().back()
		selected_resolution = fallback_resolution
		print("Current resolution not supported. Switching to fallback resolution: ", resolution_vector_to_string(fallback_resolution))
	else:
		print("Current resolution is supported: ", resolution_vector_to_string(selected_resolution))
	return selected_resolution

func sort_resolution_list() -> void:
	# Create a temporary list to store resolutions as Vector2i
	var sorted_resolutions = []
	for resolution_key in resolutions.keys():
		sorted_resolutions.append(resolutions[resolution_key])
	
	# Sort the list of resolutions using custom comparison
	sorted_resolutions.sort_custom(compare_resolutions)

	# Clear the resolutions dictionary and rebuild it in sorted order
	resolutions.clear()
	for resolution in sorted_resolutions:
		var key = resolution_vector_to_string(resolution)
		resolutions[key] = resolution
	
	print("Resolutions sorted:", resolutions)

func compare_resolutions(a: Vector2i, b: Vector2i) -> int:
	# Sort primarily by width (x), and secondarily by height (y), both in descending order
	if a.x != b.x:
		return a.x >= b.x # Descending order by width
	return b.y - a.y # Descending order by height (if widths are equal)


func set_screen_settings(new_window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN, selected_resolution:Vector2i = Vector2i(0,0)) -> void:	
	check_if_current_device_screen_size_is_in_list()
	update_resolution_list()
	sort_resolution_list()
	if(new_window_mode == null):
		new_window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN
	#print("selected resolution: " + str(selected_resolution))
	if(selected_resolution == Vector2i(0,0)):
		selected_resolution = DisplayServer.screen_get_size()
		
	selected_resolution = check_if_selected_resolution_is_supported(selected_resolution)

	save_settings_data["screen"] = {
		"window_mode" = new_window_mode,
		"window_width" = selected_resolution.x,
		"window_height" = selected_resolution.y,
	}

func set_window_size(resolution_key:String) -> void:
	var resolution_to_set = resolutions[resolution_key]
	
	if(DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN && DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_MAXIMIZED):
		#print("KEY USED: " + str(resolution_key))
		#print("OBJECT FOUND: " + str(resolution_to_set))
		get_window().set_size(resolution_to_set)
		center_window()
	#print("PRINTING THE KEY AGAIN " + str(resolution_to_set))	
	set_screen_settings(get_window_mode(),resolution_to_set)

#func set_keybind_settings() -> void:
	#save_settings_data["keybinds"] = create_keybinds_dictionary()

func resolution_vector_to_string(resolution:Vector2i):
	return str(resolution.x) + "x" + str(resolution.y)

#func on_keybind_settings_loaded(keybind_data:Dictionary) -> void:
	#var loaded_move_left = InputEventKey.new()
	#var loaded_move_right = InputEventKey.new()
	#var loaded_move_up = InputEventKey.new()
	#var loaded_move_down = InputEventKey.new()
	#var loaded_pause_game = InputEventKey.new()
	#
	#loaded_move_left.set_physical_keycode(int(keybind_data.move_left))
	#loaded_move_right.set_physical_keycode(int(keybind_data.move_right))
	#loaded_move_up.set_physical_keycode(int(keybind_data.move_up))
	#loaded_move_down.set_physical_keycode(int(keybind_data.move_down))
	#loaded_pause_game.set_physical_keycode(int(keybind_data.pause_game))

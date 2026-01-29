extends Node

func _ready() -> void:
	pass

func compare_versions() -> void:
	pass
	
func is_version_up_to_date() -> void:
	pass	
	
func get_current_version() -> void:
	pass
	
func get_saved_version() -> void:
	pass
	
func update_to_latest_version() -> void:
	pass	

# Recursieve helperfunctie om dictionaries samen te voegen
func merge_recursive(old_dict: Dictionary, new_dict: Dictionary) -> Dictionary:
	var merged_dict = {}
	for key in new_dict.keys():
		if old_dict.has(key):
			if typeof(old_dict[key]) == TYPE_DICTIONARY and typeof(new_dict[key]) == TYPE_DICTIONARY:
				# Recursief samenvoegen als de waarde een dictionary is
				merged_dict[key] = merge_recursive(old_dict[key], new_dict[key])
			else:
				# Gebruik de waarde van de oude save
				merged_dict[key] = old_dict[key]
		else:
			# Key alleen in de nieuwe save, standaardwaarde instellen
			merged_dict[key] = null
	return merged_dict

# Hoofdfunctie om de save files te vergelijken en samen te voegen
func compare_and_merge_saves(old_save: Dictionary, new_save: Dictionary) -> Dictionary:
	"""
	Vergelijk twee save files en pas de nieuwe save file aan.
	- Keys die in beide bestanden voorkomen, behouden de waarde van de oude save.
	- Keys die alleen in de nieuwe save voorkomen, krijgen een standaardwaarde (null).
	- Keys die alleen in de oude save voorkomen, worden genegeerd.
	"""
	return merge_recursive(old_save, new_save)

func update_settings_null_values() -> void:
	for category in SettingsManager.save_settings_data.keys():
		var settings = SettingsManager.save_settings_data[category]
		if typeof(settings) == TYPE_DICTIONARY:
			for key in settings.keys():
				if settings[key] == null:
					match category:
						"audio":
							if key == "music_volume" or key == "sfx_volume":
								SettingsManager.set_audio_settings()
						"screen":
							if key == "window_mode" or key == "window_width" or key == "window_height":
								SettingsManager.set_screen_settings()
						"graphics":
							if key == "show_damage_numbers":
								SettingsManager.set_graphic_settings(true)
						"accessibility":
							if key == "displayed_language":
								SettingsManager.set_displayed_language("en")

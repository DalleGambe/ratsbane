extends HSlider

@onready var value_label: Label = %AmountLabel

@export var last_value:int = 0

func _ready():
	call_deferred("_update_label_position") 
	value_changed.connect(_on_value_changed)

func set_label_theme_type_variation(theme:String):
	value_label.theme_type_variation = theme

func set_text_label(text:String):
	value_label.text = text

func _on_value_changed(value):
	_update_label_position()
	#var pitch_settings = {}
	#if(last_value < value):
		#pitch_settings["min_pitch"] = 0.8;
		#pitch_settings["max_pitch"] = 1.0;
	#else:
		#pitch_settings["min_pitch"] = 1.0;
		#pitch_settings["max_pitch"] = 1.2;
	#if(last_value != value):
		#await get_tree().create_timer(0.25).timeout
		#AudioManager.create_2d_audio_at_location(global_position, SoundEffectSettings.SOUND_EFFECT_TYPE.UI, "progress_bar_tick_1", pitch_settings)
	last_value = value	

func _update_label_position():
	if not value_label:
		return
		
	var grabber_icon = get_theme_icon("grabber")
	var grabber_width = grabber_icon.get_width()
	
	var ratio = 0.0
	if max_value > min_value:
		ratio = (value - min_value) / (max_value - min_value)
	
	var available_width = size.x - grabber_width
	
	var grabber_center_x = (ratio * available_width) + (grabber_width / 2.0)
	
	value_label.position.x = grabber_center_x - (value_label.size.x / 2.0)

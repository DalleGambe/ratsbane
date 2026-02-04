extends Node

var sound_effect_dict: Dictionary = {}
var playing_count: Dictionary = {}
var combo_tracker: Dictionary = {} 

const MAJOR_SCALE = [0, 2, 4, 7, 9, 12, 14, 16, 19, 21, 24]
@export var sound_effect_settings: Array[SoundEffectSettings]

func _ready():
	for s in sound_effect_settings:
		sound_effect_dict[s.type] = s
		playing_count[s.type] = 0

func has_open_limit(type: SoundEffectSettings.SOUND_EFFECT_TYPE) -> bool:
	if not sound_effect_dict.has(type): return false
	var s = sound_effect_dict[type]
	return playing_count[type] < s.limit

func create_2d_audio_at_location(
		location: Vector2, 
		type: SoundEffectSettings.SOUND_EFFECT_TYPE, 
		sfx_name: String = "", 
		options: Dictionary = {}
	):

	if not sound_effect_dict.has(type): return
	if not has_open_limit(type): return

	var s = sound_effect_dict[type]
	
	if not combo_tracker.has(type):
		combo_tracker[type] = { "last_time_ms": 0, "count": 0, "last_player": null }
	
	var tracker = combo_tracker[type]

	var pitch_scale = 1.0
	var use_combo = s.get("is_consecutive") or options.get("use_combo", false)
	
	if use_combo:
		var window = options.get("combo_window", 800) 
		var current_time = Time.get_ticks_msec()
		
		if current_time - tracker["last_time_ms"] < window:
			tracker["count"] += 1
		else:
			tracker["count"] = 0 
			
		tracker["last_time_ms"] = current_time
		
		var note_index = min(tracker["count"], MAJOR_SCALE.size() - 1)
		var semitones = MAJOR_SCALE[note_index]
		
		pitch_scale = pow(2.0, semitones / 12.0)
		
		if is_instance_valid(tracker["last_player"]):
			playing_count[type] = max(0, playing_count[type] - 1)
			tracker["last_player"].queue_free()

	playing_count[type] += 1

	var audio := RandomAudioPlayerComponent.new()
	audio.position = location
	audio.bus = "Sfx"
	audio.audio_stream_list = s.sound_effects
	
	audio.min_pitch = s.min_pitch * pitch_scale
	audio.max_pitch = s.max_pitch * pitch_scale 
	audio.volume_db = options.get("volume", s.volume)

	audio.finished.connect(_on_audio_finished.bind(type))
	audio.finished.connect(audio.queue_free)

	add_child(audio)
	
	if sfx_name != "":
		audio.play_random_audio(sfx_name)
	else:
		audio.play_random_audio()
		
	if use_combo:
		tracker["last_player"] = audio

func _on_audio_finished(type: SoundEffectSettings.SOUND_EFFECT_TYPE):
	playing_count[type] = max(0, playing_count[type] - 1)

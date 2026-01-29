#extends Node
#
#var sound_effect_dict: Dictionary = {}
#var playing_count: Dictionary = {}
#
#@export var sound_effect_settings: Array[SoundEffectSettings]
#
#func _ready():
	## Build lookup tables
	#for s in sound_effect_settings:
		#sound_effect_dict[s.type] = s
		#playing_count[s.type] = 0
#
#
#func has_open_limit(type: SoundEffectSettings.SOUND_EFFECT_TYPE) -> bool:
	#var s:Object = sound_effect_dict[type]
	#return playing_count[type] < s.limit
#
#func create_2d_audio_at_location(
		#location: Vector2,
		#type: SoundEffectSettings.SOUND_EFFECT_TYPE,
		#sfx_name: String = "",
		#options: Dictionary = {},
	#):
#
	#if not sound_effect_dict.has(type):
		#push_error("AudioManager: No settings found for type ", type)
		#return
#
	#if not has_open_limit(type):
		#return
#
	#var s:Object = sound_effect_dict[type]
	#playing_count[type] += 1
#
	## Create audio player
	#var audio := RandomAudioPlayerComponent.new()
	#audio.position = location
	#audio.bus = "Sfx"
	#audio.audio_stream_list = s.sound_effects
	#audio.volume_db = options["volume"] if options.has("volume") else s.volume
	#audio.min_pitch = options["min_pitch"] if options.has("min_pitch") else s.min_pitch
	#audio.max_pitch = options["max_pitch"] if options.has("max_pitch") else s.max_pitch
#
	#audio.finished.connect(_on_audio_finished.bind(type))
	#audio.finished.connect(audio.queue_free)
#
	#add_child(audio)
#
	## Play requested or random audio
	#if sfx_name != "":
		#audio.play_random_audio(sfx_name)
	#else:
		#audio.play_random_audio()
#
#func _on_audio_finished(type: SoundEffectSettings.SOUND_EFFECT_TYPE):
	## Decrement safely
	#playing_count[type] = max(0, playing_count[type] - 1)

extends Node

var sound_effect_dict: Dictionary = {}
var playing_count: Dictionary = {}
# Tracker now stores the 'last_player' node so we can kill it
var combo_tracker: Dictionary = {} 

# A Major Scale (Do Re Mi Fa Sol La Ti Do)
# These are semitone offsets.
#const MAJOR_SCALE = [0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 17, 19]
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
	
	# --- STEP 1: PREPARE TRACKER ---
	if not combo_tracker.has(type):
		combo_tracker[type] = { "last_time_ms": 0, "count": 0, "last_player": null }
	
	var tracker = combo_tracker[type]

	# --- STEP 2: CALCULATE PITCH ---
	var pitch_scale = 1.0
	var use_combo = s.get("is_consecutive") or options.get("use_combo", false)
	
	if use_combo:
		# 800ms window to keep the streak
		var window = options.get("combo_window", 800) 
		var current_time = Time.get_ticks_msec()
		
		# Logic: Increment or Reset
		if current_time - tracker["last_time_ms"] < window:
			tracker["count"] += 1
		else:
			tracker["count"] = 0 # Reset to "Do" (Root note)
			
		tracker["last_time_ms"] = current_time
		
		# --- THE MAGIC: Snap to Scale ---
		# We look up the note in our const Array. 
		# If count is higher than array size, we clamp to the highest note.
		var note_index = min(tracker["count"], MAJOR_SCALE.size() - 1)
		var semitones = MAJOR_SCALE[note_index]
		
		# Convert semitones to Godot Pitch Scale (2^(n/12))
		pitch_scale = pow(2.0, semitones / 12.0)
		
		# --- STEP 3: THE "STEAMBOAT" KILLER ---
		# If the previous sound for this type is still playing, kill it.
		# This makes it Monophonic per type. Super snappy.
		if is_instance_valid(tracker["last_player"]):
			playing_count[type] = max(0, playing_count[type] - 1)
			tracker["last_player"].queue_free()

	# --- STEP 4: PLAY NEW SOUND ---
	playing_count[type] += 1

	var audio := RandomAudioPlayerComponent.new()
	audio.position = location
	audio.bus = "Sfx"
	audio.audio_stream_list = s.sound_effects
	
	# Apply the musical pitch
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
		
	# Store this player so we can kill it next time
	if use_combo:
		tracker["last_player"] = audio

func _on_audio_finished(type: SoundEffectSettings.SOUND_EFFECT_TYPE):
	playing_count[type] = max(0, playing_count[type] - 1)

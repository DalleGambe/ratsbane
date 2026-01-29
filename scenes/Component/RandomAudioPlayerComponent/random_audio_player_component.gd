extends AudioStreamPlayer2D
class_name RandomAudioPlayerComponent

@export var min_pitch:float = 0.90
@export var max_pitch:float = 1.10
@export var randomize_pitch:bool = true

@export var audio_stream_list: Array[AudioStream]
var base_volume

func _ready() -> void:
	base_volume = volume_db

func play_random_audio(contains_name:String = "", volume:float=0.0, position_to_play_at: float = 0.0) -> void:
	#This filtering does not appear to work for some reason
	if(audio_stream_list == null or audio_stream_list.is_empty()):
		return
	if(volume != 0):
		volume_db = volume

	if randomize_pitch == true:
		pitch_scale = randf_range(min_pitch, max_pitch)
	else:
		pitch_scale =  1
	if(contains_name != ""):
		var filtered_audio_list = []
		for audio in audio_stream_list:
			if((contains_name in get_audiostream_name(audio)) == true):
				filtered_audio_list.append(audio)
		if(filtered_audio_list.size() > 0):		
			stream = filtered_audio_list.pick_random()
		else:		
			stream = audio_stream_list.pick_random()	
	else:		
		stream = audio_stream_list.pick_random()
				
	play(position_to_play_at)

func play_requested_track(requested_track:String, volume:float=0.0, start_position:float=0.0,) -> void:
		#print(requested_track)
		#print("GOING IN")
		#print("Size: " + str(audio_stream_list.size()))
		#if(volume != 0):
			#volume_db = volume
		#elif(base_volume != null):
			#volume_db = base_volume
		#else:
			#volume_db = 0.0	
		for audio in audio_stream_list:
			#print("Audio available: " + get_audiostream_name(audio))
			if((requested_track in get_audiostream_name(audio)) == true):
				#print("playing track " + requested_track)
				stream = audio
				break
		play(start_position)
		
func is_stream_in_contains_name (_stream:AudioStream, contain_part:String) -> bool:
	return contain_part in get_audiostream_name(_stream)

#func play_random_audio_and_disappear(contains_name:String = "") -> void:
	#play_random_audio(contains_name)
	#await finished
	#queue_free()
	
func get_audiostream_name(audio_stream: AudioStream) -> String:
	if audio_stream != null and audio_stream.resource_path != "":
		# Extract the file name from the resource path
		var file_name = audio_stream.resource_path.get_file()
		return file_name
	else:
		return "Unnamed AudioStream"

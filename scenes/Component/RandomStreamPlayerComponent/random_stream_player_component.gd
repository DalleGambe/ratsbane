extends AudioStreamPlayer
class_name RandomSteamPlayerComponent

@export var min_pitch:float = 0.90
@export var max_pitch:float = 1.10
@export var randomize_pitch:bool = true

@export var audio_stream_list: Array[AudioStream]

func play_random_audio(contains_name:String = "", volume:float=0.0, position: float = 0.0) -> void:
	#This filtering does not appear to work for some reason
	if(audio_stream_list == null or audio_stream_list.is_empty()):
		return
	if(volume != 0):
		volume_db = volume

	if randomize_pitch == true:
		pitch_scale = randf_range(min_pitch, max_pitch)
	else:
		pitch_scale =  1
	#print(contains_name)
	if(contains_name != ""):
		var filtered_audio_list = []
		for audio in audio_stream_list:
			if((contains_name in get_audiostream_name(audio)) == true):
				filtered_audio_list.append(audio)
		if not filtered_audio_list.is_empty():
			stream = filtered_audio_list.pick_random()
	else:		
		stream = audio_stream_list.pick_random()
				
	play(position)

func play_requested_track_with_pitch(requested_track:String, min_pitch:float=1.0, max_pitch:float=1.0) -> void:
		pitch_scale = randf_range(min_pitch, max_pitch)
		play_requested_track(requested_track)
		
func play_requested_track(requested_track:String, start_position:float=0.0) -> void:
		for audio in audio_stream_list:
			if((requested_track in get_audiostream_name(audio)) == true):
				stream = audio
				break
		play(start_position)

func play_requested_track_by_index(index:int) -> void:
		stream = audio_stream_list[min(index, audio_stream_list.size()-1)]
		play()

func set_pitch(new_min_pitch:float = 1,new_max_pitch:float=1) -> void:
	min_pitch = new_min_pitch   
	max_pitch = new_max_pitch

func is_stream_in_contains_name (_stream:AudioStream, contain_part:String) -> bool:
	return contain_part in get_audiostream_name(_stream)

func get_audiostream_name(audio_stream: AudioStream) -> String:
	if audio_stream != null and audio_stream.resource_path != "":
		# Extract the file name from the resource path
		var file_name = audio_stream.resource_path.get_file()
		return file_name
	else:
		return "Unnamed AudioStream"

extends AudioStreamPlayer

@export var audio_stream_list: Array[AudioStream]

var base_volume:float
var track_playing:String
var volume_of_track_playing:float 
var audio_loop

func _ready():
	finished.connect(_on_finished)
	base_volume = volume_db

func play_requested_track(requested_track:String, volume:float = base_volume) -> void:
		volume_of_track_playing = volume
		volume_db = volume_of_track_playing
		#print("Volume of track playing: " + str(volume_of_track_playing))
		var audiostream_name
		for audio in audio_stream_list:
			audiostream_name = get_audiostream_name(audio)
			if(requested_track in audiostream_name):
				stream = audio
				break
		play()
		
func get_audiostream_name(audio_stream: AudioStream) -> String:
	if audio_stream != null and audio_stream.resource_path != "":
		# Extract the file name from the resource path
		var file_name = audio_stream.resource_path.get_file()
		var dot_index = file_name.find(".")
		#print(dot_index)
		if dot_index != -1:
			track_playing = file_name.substr(0, dot_index)
			#print(track_playing)
		return file_name
	else:
		return "Unnamed AudioStream"
		
func switch_music_momentum_to(new_pitch_scale:float = 1.2) -> void:
	pitch_scale = new_pitch_scale

func _on_finished() -> void:
	audio_loop = track_playing + "_loop"
	# Plays the current track over if the loop is not found
	play_requested_track(audio_loop, volume_of_track_playing)
	#print("Volume of loop playing: " + str(volume_of_track_playing))

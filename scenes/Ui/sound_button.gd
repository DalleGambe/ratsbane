extends Button

@onready var random_stream_player_component: RandomSteamPlayerComponent = %RandomStreamPlayerComponent
@export var sfx_list: Array[AudioStream]

func _ready() -> void:
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	if not (sfx_list == null or sfx_list.is_empty()):
		random_stream_player_component.audio_stream_list = sfx_list

func _on_pressed() -> void:
	random_stream_player_component.play_random_audio("button_click")

func _on_mouse_entered() -> void:
	if not (disabled):
		random_stream_player_component.min_pitch = 1
		random_stream_player_component.max_pitch = 1
		random_stream_player_component.play_random_audio("button_hover")

#
#extends Button
#
#@onready var random_stream_player_component: RandomSteamPlayerComponent = %RandomStreamPlayerComponent
#@export var sfx_list: Array[AudioStream]
#@export var filter_pressed_name: String
#@export var filter_hover_name: String
#
#func _ready() -> void:
	#pressed.connect(_on_pressed)
	#mouse_entered.connect(_on_mouse_entered)
	#if not (sfx_list == null or sfx_list.is_empty()):
		#random_stream_player_component.audio_stream_list = sfx_list
#
#func _on_pressed() -> void:
	#if(filter_pressed_name != ""):
		#random_stream_player_component.play_random_audio("button_click")
	#else:
		#random_stream_player_component.play_random_audio(filter_pressed_name)
#
#func _on_mouse_entered() -> void:
	#if not (disabled):
		#random_stream_player_component.min_pitch = 1
		#random_stream_player_component.max_pitch = 1
		#if(filter_hover_name != ""):
			#random_stream_player_component.play_random_audio("button_hover")
		#else:
			#random_stream_player_component.play_random_audio(filter_hover_name)

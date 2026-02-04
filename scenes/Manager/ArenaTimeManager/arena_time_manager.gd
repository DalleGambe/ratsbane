extends Node

const DIFFICULTY_INTERVAL = 5

@export var end_screen: PackedScene

@onready var timer = %TimeLeft
@onready var difficulity_interval_timer = %DifficultyIntervalTimer
@onready var music_momentum_timer: Timer = %MusicMomentumTimer
@onready var open_door_timer: Timer = %OpenDoorTimer
@onready var random_steam_player_component: RandomSteamPlayerComponent = $RandomSteamPlayerComponent

signal arena_difficulty_increased(arena_difficulity: int)

var arena_difficulity:float = 0
var base_wait_for_next_wave_time = 5
const TIMER_LIMIT = 2.0
var timer2 = 0.0

func _ready() -> void:
	open_door_timer.timeout.connect(_on_open_door_timer_timeout)
	music_momentum_timer.timeout.connect(_on_music_momentum_timer_timout)
	difficulity_interval_timer.timeout.connect(_on_difficulty_interval_timer_timeout)
	# Didn't turn on Autostart for possible future programming
	difficulity_interval_timer.wait_time = base_wait_for_next_wave_time
	music_momentum_timer.wait_time = open_door_timer.wait_time * 0.80
	difficulity_interval_timer.start()
	open_door_timer.start()
	music_momentum_timer.start()

func _process(delta):
	timer2 += delta
	if timer2 > TIMER_LIMIT: 
		timer2 = 0.0
		print("fps: " + str(Engine.get_frames_per_second()))

func _get_time_elapsed() -> float:
	return timer.wait_time - timer.time_left

func _on_open_door_timer_timeout() -> void:
	GameEvents.emit_door_to_next_area_should_open()

func _on_music_momentum_timer_timout() -> void:
	MusicPlayer.switch_music_momentum_to(1.2)
	random_steam_player_component.play_random_audio()
func _on_difficulty_interval_timer_timeout() -> void:
		arena_difficulity+=1
		difficulity_interval_timer.wait_time = DIFFICULTY_INTERVAL
		arena_difficulty_increased.emit(arena_difficulity)

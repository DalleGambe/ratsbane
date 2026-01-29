extends Resource
class_name SoundEffectSettings
enum SOUND_EFFECT_TYPE{
	OBJECT_PICKUP,
	BOMB_EXPLOSION,
	BOW_BEING_FIRED,
	BOW_BEING_PREPARED,
	GAINED_HP,
	CARD_ENTER,
	PINBALL_HIT,
	ARCANE_EXPLOSION,
	ARCANE_BOLT_BEING_SUMMONED,
	PLAYER,
	UI,
}

@export_range(0, 10) var limit : int = 5
@export var type : SOUND_EFFECT_TYPE
@export var sound_effects : Array[AudioStream]
@export_range(-40, 25) var volume  = 0
@export_range(0.0, 4.0,.01) var pitch_scale = 1.0
@export_range(0.0, 5.0,.01) var min_pitch = 1.0
@export_range(0.0, 5.0,.01) var max_pitch = 1.0
@export var randomize_pitch: bool = false
@export_range(0.0, 1.0,.01) var pitch_randomness = 0.0
@export var is_consecutive:bool = false
	

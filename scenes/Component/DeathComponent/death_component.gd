extends Node2D

@export var health_component:HealthComponent
@export var sprite:Sprite2D
@export var random_audio_player:RandomAudioPlayerComponent

var local_sfx_player: RandomAudioPlayerComponent

func _ready():
	local_sfx_player = %RandomSfxPlayerComponent as RandomAudioPlayerComponent
	if(random_audio_player != null):
		local_sfx_player.audio_stream_list = random_audio_player.audio_stream_list
	if(sprite != null):
		%GPUParticles2D.texture = sprite.texture
	health_component.health_owner_died.connect(on_owner_died)

func on_owner_died():
	if(owner == null || not owner is Node2D):
		return
	var spawn_position = owner.global_position
	var entities = get_tree().get_first_node_in_group("entities_group")
	get_parent().remove_child(self)
	entities.add_child(self)
	
	global_position = spawn_position
	%AnimationPlayer.play("default")
	if(local_sfx_player != null):
		local_sfx_player.play_random_audio()

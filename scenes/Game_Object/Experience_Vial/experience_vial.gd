extends Node2D

@export var amount_of_experience:int = 1
@export var exp_sprite_texture: Texture2D

@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var exp_sprite = %ExpSprite2D

func _ready() -> void:
	if(exp_sprite_texture != null):
		exp_sprite.texture = exp_sprite_texture

func tween_collect(percentage:float, start_position:Vector2) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return
	global_position = start_position.lerp(player.global_position, percentage)	
	var direction_from_start = player.global_position - start_position
	var target_rotation = direction_from_start.angle() + deg_to_rad(90)
	rotation = lerp_angle(rotation, target_rotation, 1-exp(-2 * get_process_delta_time()))
	
func collect() -> void:
	GameEvents.emit_experience_vial_collected(amount_of_experience)
	queue_free()

func disable_collision() -> void:
	collision_shape_2d.disabled = true

func _on_area_2d_area_entered(area: Area2D) -> void:
	Callable(disable_collision).call_deferred()
	var tween = create_tween()
	tween.set_parallel()
	var animation_duration:float = 0.8
	tween.tween_method(tween_collect.bind(global_position), 0.0, 1.0, animation_duration)\
	.set_ease(Tween.EASE_IN)\
	.set_trans(Tween.TRANS_BACK)
	tween.tween_property(exp_sprite, "scale", Vector2.ZERO, .15).set_delay(0.65)
	tween.chain()
	tween.tween_callback(collect)
	var delay:float = 0.55
	await get_tree().create_timer(delay).timeout
	AudioManager.create_2d_audio_at_location(global_position,  SoundEffectSettings.SOUND_EFFECT_TYPE.OBJECT_PICKUP, "exp_pickup_1", {
	"use_combo": true,
})

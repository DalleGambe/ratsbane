extends Node2D
@onready var label: Label = %Label

func spawn_animation(text: String):
	%Label.text = text
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "global_position", global_position + (Vector2.UP * 16), 0.6)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans (Tween. TRANS_CUBIC)
	tween.chain()
	tween.tween_property(self, "global_position", global_position + (Vector2.UP * 48), 0.6)\
	.set_ease(Tween.EASE_IN)\
	.set_trans (Tween. TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2.ZERO, .4)\
	.set_ease(Tween.EASE_IN)\
	.set_trans (Tween. TRANS_CUBIC)
	
	var scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2.ONE * 1.5, 0.30)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween. TRANS_CUBIC) 
	scale_tween.tween_property(self, "scale", Vector2.ONE, 0.30)\
	.set_ease(Tween.EASE_IN).set_trans (Tween. TRANS_CUBIC)

func grow_animation(size_increase:float) -> void:
	var new_size = Vector2.ONE * (1 + size_increase)
	var scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", (new_size + (Vector2.ONE * 0.15)), 0.30)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween. TRANS_CUBIC) 
	scale_tween.tween_property(self, "scale", new_size, 0.30)\
	.set_ease(Tween.EASE_IN).set_trans (Tween. TRANS_CUBIC)

func start_merge(percentage:float, start_position:Vector2, end_position:Vector2) -> void:
	global_position = start_position.lerp(end_position, percentage)	
	var direction_from_start = end_position - start_position
	var target_rotation = direction_from_start.angle() + deg_to_rad(90)

func finish_merge() -> void:
	GameEvents.emit_near_miss_merge()
	return_to_pool()
	
func merge_animation(point_to_travel_to:Vector2) -> void:
	var animation_duration:float = 0.8
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_method(start_merge.bind(global_position, point_to_travel_to), 0.0, 1.0, animation_duration)\
	.set_ease(Tween.EASE_IN)\
	.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2.ZERO, .15).set_delay(0.65)
	tween.chain()
	tween.tween_callback(finish_merge)
	var delay:float = 0.55
	await get_tree().create_timer(delay).timeout
	AudioManager.create_2d_audio_at_location(global_position, SoundEffectSettings.SOUND_EFFECT_TYPE.OBJECT_PICKUP, "exp_pickup_1", {
	"use_combo": true,
})
	
func return_to_pool():
	FloatingTextManager.call_deferred("return_floating_text", self, "near_miss")

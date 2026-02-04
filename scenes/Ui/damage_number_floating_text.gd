extends Node2D

func start_animation(text: String):
	%Label.text = Util.format_float_to_string(float(text)) if text.is_valid_float() else text

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
	tween.chain()
	tween.tween_callback(return_to_pool)  # Return to pool instead of freeing
	
	var scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2.ONE * 1.5, 0.30)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween. TRANS_CUBIC) 
	scale_tween.tween_property(self, "scale", Vector2.ONE, 0.30)\
	.set_ease(Tween.EASE_IN).set_trans (Tween. TRANS_CUBIC)
	
	# Add this new function in the floating text script to return the object to the pool
func return_to_pool():
		FloatingTextManager.call_deferred("return_floating_text", self, "damage_number")

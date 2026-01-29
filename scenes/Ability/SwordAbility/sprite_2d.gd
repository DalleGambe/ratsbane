extends Sprite2D

func UpdateAlpha(new_value: float) -> void:
	modulate.a = new_value

func StartFading() -> void:
	var tween = get_tree().create_tween()
	tween.tween_method(UpdateAlpha, 0.8, 0.0, 1.0)
	await tween.finished
	queue_free()

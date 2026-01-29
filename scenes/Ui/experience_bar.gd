extends CanvasLayer

@export var experience_manager: ExperienceManager
@onready var progress_bar = %ProgressBar

func _ready():
	progress_bar.value = 0
	experience_manager.experience_updated.connect(on_experience_updated)
	
func on_experience_updated(current_experience: float, target_experience: float) -> void:
	if target_experience == 0:
		return

	var target_progress = current_experience / target_experience
	
	# Ensure the pivot is always center so it scales from the middle
	progress_bar.pivot_offset = progress_bar.size / 2

	var fill_tween = create_tween()
	fill_tween.tween_property(progress_bar, "value", target_progress, 0.4)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)

	var scale_tween = create_tween()
	
	scale_tween.tween_property(progress_bar, "scale", Vector2.ONE * 1.1, 0.1)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
	
	scale_tween.tween_property(progress_bar, "scale", Vector2.ONE, 0.3)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)

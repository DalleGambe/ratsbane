extends Label
class_name AnimatedLabel
@export var displayed_text:String = "rat"

func _ready() -> void:
	pivot_offset = size / 2
	_set_text(displayed_text)
	#var tween = create_tween()
	#tween.set_parallel()
	#tween.tween_property(self, "position:y", position.y+4, 0.6)\
	#.set_ease(Tween.EASE_IN)\
	#.set_trans (Tween.TRANS_SINE)
	#tween.chain()	
	#tween.tween_property(self, "position:y",position.y-10, 0.6)\
	#.set_ease(Tween.EASE_IN)\
	#.set_trans (Tween.TRANS_SINE)
	#tween.chain()
	#tween.tween_property(self, "position:y", position.y+4, 0.6)\
	#.set_ease(Tween.EASE_IN)\
	#.set_trans (Tween.TRANS_SINE)
	#tween.chain()
	#tween.tween_property(self, "position:y",position.y-10, 0.6)\
	#.set_ease(Tween.EASE_IN)\
	#.set_trans (Tween.TRANS_SINE)
	#tween.chain()
	#tween.set_loops(0)
	#
#func tween_method(percentage:float, start_position:Vector2) -> void:
	#global_position = start_position.lerp(global_position, percentage)	

func _set_text(new_text:String) -> void:
	text = new_text

extends ProgressBar

@export var color1: Color = Color(0.639, 0.361, 0.865, 1.0)
@export var color2: Color = Color(0.549, 0.204, 0.792, 1.0)
@export var glow_speed: float = 1.0  
@export var intensity: float = 1.5  

var t: float = 0.0  
var flicker:bool = false
var base_ability_power_bar_color:Color = color1

func _process(delta):
	if(flicker == true):
		t += delta * glow_speed 
		
		var alpha = 0.5 + 0.5 * sin(t * TAU) 
		
		var glow_color = color1.lerp(color2, alpha) 
		
		glow_color.r = pow(glow_color.r, 1.0 / intensity)
		glow_color.g = pow(glow_color.g, 1.0 / intensity)
		glow_color.b = pow(glow_color.b, 1.0 / intensity)

		var stylebox = get_theme_stylebox("fill")
		if stylebox:
			stylebox.bg_color = glow_color
	elif(get_theme_stylebox("fill").bg_color != base_ability_power_bar_color):
		get_theme_stylebox("fill").bg_color = base_ability_power_bar_color		

func set_flickering_to(should_flicker:bool) -> void:
	flicker = should_flicker
	
func bounce() -> void:
	var scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2.ONE * 1.10, 0.30)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween. TRANS_CUBIC) 
	scale_tween.tween_property(self, "scale", Vector2.ONE, 0.30)\
	.set_ease(Tween.EASE_IN).set_trans (Tween. TRANS_CUBIC)

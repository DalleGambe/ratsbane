extends ProgressBar

@export var color1: Color = Color(0.639, 0.361, 0.865, 1.0)
@export var color2: Color = Color(0.549, 0.204, 0.792, 1.0)
@export var glow_speed: float = 1.0  # Speed of transition
@export var intensity: float = 1.5  # Intensity of the glow

var t: float = 0.0  # Timer for smooth transition
var flicker:bool = false
var base_healthbar_color:Color = Color(0.141, 0.588, 0.412, 1.0)

func _process(delta):
	if(flicker == true):
		t += delta * glow_speed  # Increment time
		
		# Oscillate between 0 and 1 smoothly
		var alpha = 0.5 + 0.5 * sin(t * TAU) 
		
		# Smoothly blend colors
		var glow_color = color1.lerp(color2, alpha) 
		
		# Adjust intensity
		glow_color.r = pow(glow_color.r, 1.0 / intensity)
		glow_color.g = pow(glow_color.g, 1.0 / intensity)
		glow_color.b = pow(glow_color.b, 1.0 / intensity)

		# Apply to ProgressBar fill
		var stylebox = get_theme_stylebox("fill")
		if stylebox:
			stylebox.bg_color = glow_color
	elif(get_theme_stylebox("fill").bg_color != base_healthbar_color):
		get_theme_stylebox("fill").bg_color = base_healthbar_color		

func set_flickering_to(should_flicker:bool) -> void:
	flicker = should_flicker		

shader_type canvas_item;

uniform vec4 transition_texture_color: source_color;
uniform sampler2D transition_texture: filter_nearest;
uniform float percentage: hint_range(0.0, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

// Runs every frame for a texture
void fragment() {
	// Grabbing color from texture as same UV as the pixel that is being considered for the shader
	vec4 transition_color = texture(transition_texture, UV);
	if(transition_color.r > percentage) {
		COLOR.a = 0.0;
	}
	else {
		COLOR = transition_texture_color;
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

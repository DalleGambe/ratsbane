shader_type canvas_item;

uniform vec4 color1 : source_color = vec4(0.639, 0.361, 0.865, 1.0); // Start color for the glow
uniform vec4 color2 : source_color = vec4(0.549, 0.204, 0.792, 1.0); // End color for the glow
uniform float width : hint_range(0, 10) = 1.0; // Glow width
uniform int pattern : hint_range(0, 2) = 0; // Pattern: 0 = diamond, 1 = circle, 2 = square
uniform bool inside = false; // Glow inside
uniform bool add_margins = true; // Extend sprite margins for glow
uniform vec2 number_of_images = vec2(1.0); // Spritesheet support
uniform float time : hint_range(0, 1000); // Time for animation
uniform float glow_speed : hint_range(0.1, 5.0) = 1.0; // Speed of color cycling
uniform float intensity : hint_range(0.5, 5.0) = 1.5; // Intensity of the glow
uniform float edge_softness : hint_range(0.1, 2.0) = 1.0; // Controls gradient edge softness
uniform bool glow_is_active = true;
varying vec4 MODULATE;

void vertex() {
    if (add_margins && glow_is_active == false) {
        VERTEX += sign(VERTEX) * width;
    }
    MODULATE = COLOR;
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, vec2 image_top_left, vec2 image_bottom_right, sampler2D texture) {
    if(glow_is_active == true) {
		for (float i = -ceil(width); i <= ceil(width); i++) {
        float x = abs(i) > width ? width * sign(i) : i;
        float offset;

        if (pattern == 0) {
            offset = width - abs(x);
        } else if (pattern == 1) {
            offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
        } else if (pattern == 2) {
            offset = width;
        }

        for (float j = -ceil(offset); j <= ceil(offset); j++) {
            float y = abs(j) > offset ? offset * sign(j) : j;
            vec2 xy = uv + texture_pixel_size * vec2(x, y);

            if ((xy != clamp(xy, image_top_left, image_bottom_right) || texture(texture, xy).a <= 0.0) == inside) {
                return true;
            }
        }
    }
    return false;
	}
}

void fragment() {
	if(glow_is_active == true) {
	    vec2 uv = UV;
    vec2 image_top_left = floor(uv * number_of_images) / number_of_images;
    vec2 image_bottom_right = image_top_left + vec2(1.0) / number_of_images;

    if (add_margins) {
        vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(width * 2.0) * number_of_images);

        uv = (uv - texture_pixel_size * width - image_top_left) * TEXTURE_PIXEL_SIZE / texture_pixel_size + image_top_left;

        if (uv != clamp(uv, image_top_left, image_bottom_right)) {
            COLOR.a = 0.0;
        } else {
            COLOR = texture(TEXTURE, uv);
        }
    } else {
        COLOR = texture(TEXTURE, uv);
    }

    // Animate glow color
    float t = 0.5 + 0.5 * sin(time * glow_speed * 6.28318); // Smooth oscillation between 0 and 1
    vec4 glow_color = mix(color1, color2, t);

	if ((COLOR.a > 0.0) == inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, image_top_left, image_bottom_right, TEXTURE)) {
	    // Apply the calculated gradient edge effect
	    COLOR.rgb = inside ? mix(COLOR.rgb, glow_color.rgb, glow_color.a) : glow_color.rgb;
	    COLOR.a += (1.0 - COLOR.a) * glow_color.a;
	}

    // Increase intensity and saturation for a neon look
    glow_color.rgb = pow(glow_color.rgb, vec3(1.0 / intensity)); // Boost brightness

    if ((COLOR.a > 0.0) == inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, image_top_left, image_bottom_right, TEXTURE)) {
        COLOR.rgb = inside ? mix(COLOR.rgb, glow_color.rgb, glow_color.a) : glow_color.rgb;
        COLOR.a += (1.0 - COLOR.a) * glow_color.a;
    }

    // Apply self-modulate
    COLOR *= MODULATE;
	}
}

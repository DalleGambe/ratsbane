shader_type canvas_item;

// --- Color Replacement Uniforms ---
uniform vec4 target_color : source_color =  vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 replace_color : source_color;
uniform float tolerance : hint_range(0, 1);
uniform float blend_amount : hint_range(0, 1) = 1.0; // 0 = Keep original, 1 = Full replacement

// --- Glow / Outline Uniforms ---
uniform bool glow_is_active = true;
uniform vec4 glow_color_start : source_color = vec4(0.639, 0.361, 0.865, 1.0);
uniform vec4 glow_color_end : source_color = vec4(0.549, 0.204, 0.792, 1.0);
uniform float width : hint_range(0, 10) = 1.0;
uniform int pattern : hint_range(0, 2) = 0;
uniform bool inside = false;
uniform bool add_margins = true;
uniform vec2 number_of_images = vec2(1.0);
uniform float time_scale : hint_range(0.0, 10.0) = 1.0;
uniform float intensity : hint_range(0.5, 5.0) = 1.5;

varying vec4 MODULATE;

void vertex() {
    if (add_margins) {
        VERTEX += sign(VERTEX) * width;
    }
    MODULATE = COLOR;
}

// Checks if the pixel is on the edge of the sprite
bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, vec2 image_top_left, vec2 image_bottom_right, sampler2D tex) {
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

            if ((xy != clamp(xy, image_top_left, image_bottom_right) || texture(tex, xy).a <= 0.0) == inside) {
                return true;
            }
        }
    }
    return false;
}

void fragment() {
    vec2 uv = UV;
    vec2 image_top_left = floor(uv * number_of_images) / number_of_images;
    vec2 image_bottom_right = image_top_left + vec2(1.0) / number_of_images;

    vec4 tex_color;

    // 1. UV Handling for Margins
    if (add_margins) {
        vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(width * 2.0) * number_of_images);
        uv = (uv - texture_pixel_size * width - image_top_left) * TEXTURE_PIXEL_SIZE / texture_pixel_size + image_top_left;

        if (uv != clamp(uv, image_top_left, image_bottom_right)) {
            tex_color = vec4(0.0);
        } else {
            tex_color = texture(TEXTURE, uv);
        }
    } else {
        tex_color = texture(TEXTURE, uv);
    }

    // 2. Color Modulation (The "Tint" Effect)
    float dist = distance(tex_color.rgb, target_color.rgb);
    if (dist < tolerance) {
        // Calculate the brightness (Luminance) of the original pixel
        // These numbers (0.299, etc) match how human eyes perceive brightness
        float grayscale_value = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));

        // Multiply the replace_color by the brightness of the old pixel
        vec3 shaded_new_color = replace_color.rgb * grayscale_value;

        // Mix it based on blend_amount (allows for partial tinting)
        tex_color.rgb = mix(tex_color.rgb, shaded_new_color, blend_amount);
    }

    COLOR = tex_color;

    // 3. Glow Application
    if (glow_is_active) {
        float t = 0.5 + 0.5 * sin(TIME * time_scale * 6.28318);
        vec4 glow_cycle_color = mix(glow_color_start, glow_color_end, t);

        // Calculate edge detection once
        bool is_edge = ((COLOR.a > 0.0) == inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, image_top_left, image_bottom_right, TEXTURE));

        if (is_edge) {
            COLOR.rgb = inside ? mix(COLOR.rgb, glow_cycle_color.rgb, glow_cycle_color.a) : glow_cycle_color.rgb;
            COLOR.a += (1.0 - COLOR.a) * glow_cycle_color.a;

            // Neon intensity boost
            glow_cycle_color.rgb = pow(glow_cycle_color.rgb, vec3(1.0 / intensity));

            // Second pass for intensity
            COLOR.rgb = inside ? mix(COLOR.rgb, glow_cycle_color.rgb, glow_cycle_color.a) : glow_cycle_color.rgb;
            COLOR.a += (1.0 - COLOR.a) * glow_cycle_color.a;
        }
    }

    COLOR *= MODULATE;
}
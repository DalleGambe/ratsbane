shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 20.0) = 5.0;
uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 color = vec4(0.0);

    // Sample surrounding pixels for blur effect
    float total = 0.0;
    int radius = int(blur_amount);

    // Loop through neighboring pixels based on blur amount
    for (int x = -radius; x <= radius; x++) {
        for (int y = -radius; y <= radius; y++) {
            vec2 offset = vec2(float(x), float(y)) / vec2(textureSize(screen_texture, 0));
            color += texture(screen_texture, uv + offset);
            total += 1.0;
        }
    }

    // Average the color to create the blur
    color /= total;

    // Output the blurred screen with optional transparency for ColorRect
    COLOR = vec4(color.rgb, 1.0); // Use a lower alpha if you want transparency
}

shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

uniform int pixel_resolution_x : hint_range(64, 640) = 320;
uniform int pixel_resolution_y : hint_range(64, 480) = 240;
uniform float dither_strength : hint_range(0.0, 1.0) = 0.3;
uniform float color_depth : hint_range(1, 256) = 32;
uniform float jitter_intensity : hint_range(0.0, 1.0) = 0.0005; // Very subtle

// Bayer Dithering Function (Fixed for Pixel Scale)
float bayer_dither(vec2 uv) {
    float bayer_matrix[16] = float[16](
        0.0,  8.0,  2.0, 10.0,
        12.0, 4.0, 14.0, 6.0,
        3.0, 11.0, 1.0, 9.0,
        15.0, 7.0, 13.0, 5.0
    );

    // **Now dithering is properly scaled to the pixel resolution**
    ivec2 pixel = ivec2(int(mod(floor(uv.x * float(pixel_resolution_x)), 4.0)),
                         int(mod(floor(uv.y * float(pixel_resolution_y)), 4.0)));
    int index = pixel.y * 4 + pixel.x;
    return bayer_matrix[index] / 16.0;
}

// Pixelation (Low-Resolution Effect) - **Fixed**
vec2 pixelate(vec2 uv) {
    vec2 resolution = vec2(float(pixel_resolution_x), float(pixel_resolution_y));
    return floor(uv * resolution) / resolution;
}

// **Super Subtle** Pixel Jitter (Fixed)
vec2 jitter_uv(vec2 uv, float time) {
    float jitter_x = sin(time * 50.0) * jitter_intensity * 0.25; // Much softer
    float jitter_y = cos(time * 50.0) * jitter_intensity * 0.25;
    return uv + vec2(jitter_x, jitter_y);
}

void fragment() {
    vec2 uv = pixelate(UV); // Apply pixelation
    uv = jitter_uv(uv, TIME); // Super subtle jitter

    // Sample the screen texture
    vec4 color = texture(screen_texture, uv);

    // Reduce color depth
    color.rgb = floor(color.rgb * color_depth) / color_depth;

    // Apply dithering
    float dither_value = bayer_dither(UV); // UV is valid here
    color.rgb += (dither_value - 0.5) * dither_strength;

    COLOR = color;
}

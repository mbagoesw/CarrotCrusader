shader_type canvas_item;

uniform vec2 hole_position = vec2(0.5, 0.5); // Center position of the square (0-1 range)
uniform vec2 hole_size = vec2(0.2, 0.1); // Width & height of the square (0-1 range)
uniform vec4 overlay_color = vec4(0.0, 0.0, 0.0, 0.7); // Transparent black color

void fragment() {
    vec2 uv_pos = UV;

    // Calculate square boundaries
    vec2 half_size = hole_size * 0.5;
    vec2 min_bound = hole_position - half_size;
    vec2 max_bound = hole_position + half_size;

    // If inside the square, discard (make transparent)
    if (uv_pos.x > min_bound.x && uv_pos.x < max_bound.x &&
        uv_pos.y > min_bound.y && uv_pos.y < max_bound.y) {
        discard;
    }

    // Apply the overlay color everywhere else
    COLOR = overlay_color;
}

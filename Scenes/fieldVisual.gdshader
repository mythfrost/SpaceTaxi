shader_type canvas_item;
render_mode unshaded, blend_premul_alpha;

uniform float pulse_speed : hint_range(0.1, 20.0) = 5.0;
uniform float pulse_strength : hint_range(0.1, 1.0) = 0.5;
// our own time accumulator:
uniform float shader_time = 0.0;

void fragment() {
    vec2 uvc = (UV - vec2(0.5)) * 2.0;
    float dist = length(uvc);

    if (dist > 1.0) {
        COLOR = vec4(0.0);
    } else {
        float base_alpha = 0.3 * smoothstep(1.0, 0.5, 1.0 - dist);
        float glow = abs(sin(shader_time * pulse_speed + dist * 6.2831));
        float alpha = base_alpha + glow * pulse_strength;
        COLOR = vec4(0.2, 0.6, 1.0, alpha);
    }
}

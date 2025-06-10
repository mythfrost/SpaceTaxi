shader_type canvas_item;

uniform float strength : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    // UV runs 0→1 across the screen
    vec2 uv = SCREEN_UV;
    // compute distance from center (0.5,0.5)
    float d = distance(uv, vec2(0.5));
    // vignette factor: 0 at center, 1 at corners
    float vign = smoothstep(0.5, 0.5 + strength, d);
    // darken output by vignette
    COLOR.rgb *= 1.0 - vign;
}
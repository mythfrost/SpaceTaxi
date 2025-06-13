shader_type canvas_item;

uniform float radius    : hint_range(0.0, 1.0) = 0.6;
uniform float softness  : hint_range(0.0, 1.0) = 0.4;
uniform vec4  dark_color: hint_color = vec4(0, 0, 0, 1);

void fragment() {
    vec2 uv = SCREEN_UV - vec2(0.5);
    float dist = length(uv);
    float vig  = smoothstep(radius, radius + softness, dist);
    vec4 base  = texture(SCREEN_TEXTURE, SCREEN_UV);
    COLOR      = mix(base, dark_color, vig * dark_color.a);
}

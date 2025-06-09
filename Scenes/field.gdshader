shader_type canvas_item;
render_mode unshaded, blend_add;

uniform vec3 glow_color    = vec3(0.2, 0.6, 1.0);
uniform float pulse_speed  = 4.0;
uniform float pulse_strength = 1.0;
uniform float base_strength  = 0.5;
uniform float shader_time    = 0.0;

void fragment() {
	// Map UV to –1..1 centered circle
	vec2 uvc = (UV - vec2(0.5)) * 2.0;
	float d = length(uvc);

	// Start fully transparent
	vec4 col = vec4(0.0);

	if (d <= 1.0) {
		// Base fade‐out from center
		float base_alpha = base_strength * smoothstep(1.0, 0.5, 1.0 - d);
		// Twinkle amount
		float glow = abs(sin(shader_time * pulse_speed + d * 6.2831));
		float alpha = base_alpha + glow * pulse_strength;
		// Compose final color + computed alpha
		col = vec4(glow_color, alpha);
	}

	COLOR = col;
}

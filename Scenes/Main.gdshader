shader_type canvas_item;
render_mode unshaded, blend_premul_alpha;

uniform float star_density  : hint_range(0.0, 1.0)  = 0.2;
uniform float twinkle_speed : hint_range(0.1, 20.0) = 5.0;
uniform float star_size     : hint_range(0.002, 0.05) = 0.01;

void fragment() {
	// normalized screen UV
	vec2 uv = SCREEN_UV;
	vec4 col = vec4(0.0, 0.0, 0.0, 1.0);

	// which cell and two seeds
	vec2 cell = floor(uv / star_size);
	float seed1 = fract(sin(dot(cell, vec2(12.9898,78.233))) * 43758.5453);
	float seed2 = fract(sin(dot(cell, vec2(93.9898,67.345))) * 24634.6345);

	if (seed1 < star_density) {
		vec2 offset   = (vec2(seed2, fract(seed1*seed2)) - 0.5) * star_size;
		vec2 star_pos = (cell * star_size) + (star_size * 0.5) + offset;
		float radius  = star_size * 0.3 * (0.5 + seed2 * 0.5);

		if (distance(uv, star_pos) < radius) {
			// each star twinkles at its own rate and phase
			float local_speed = twinkle_speed * (0.5 + seed2 * 1.5);
			float phase       = seed1 * 6.2831;
			float brightness  = 0.3 + 0.7 * abs(sin(TIME * local_speed + phase));
			col = vec4(vec3(brightness), 1.0);
		}
	}

	COLOR = col;
}

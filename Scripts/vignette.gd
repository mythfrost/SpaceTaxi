extends ColorRect

# Adjustable vignette parameters (0.0 to 1.0)
@export_range(0.0, 1.0) var vignette_radius:   float = 0.35
@export_range(0.0, 1.0) var vignette_softness: float = 0.4
@export_range(0.0, 1.0) var vignette_intensity: float = 0.7

func _ready() -> void:
	# Ensure full‐screen coverage via editor Layout → Full Rect
	# Build the ShaderMaterial
	var mat := ShaderMaterial.new()
	var sh  := Shader.new()
	sh.code = """
shader_type canvas_item;
render_mode unshaded;

uniform float radius;
uniform float softness;
uniform float intensity;

void fragment() {
	// UV (0,0) bottom‐left to (1,1) top‐right, center at (0.5,0.5)
	vec2 uv = UV - vec2(0.5, 0.5);
	float d = length(uv);
	float mask = smoothstep(radius, radius + softness, d);
	// translucent black overlay
	COLOR = vec4(0.0, 0.0, 0.0, mask * intensity);
}
"""
	mat.shader = sh

	# Push exported values into shader uniforms
	mat.set_shader_parameter("radius", vignette_radius)
	mat.set_shader_parameter("softness", vignette_softness)
	mat.set_shader_parameter("intensity", vignette_intensity)

	# Assign material
	material = mat

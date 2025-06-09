extends ColorRect

var mat: ShaderMaterial

func _ready():
	mat = material as ShaderMaterial

func _process(delta):
	var t = mat.get_shader_parameter("shader_time") + delta
	mat.set_shader_parameter("shader_time", t)

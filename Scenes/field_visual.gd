extends ColorRect
#Caches the shader material on ready and increments its time uniform each frame so the pulsing animation runs.
var mat: ShaderMaterial

func _ready():
	mat = material as ShaderMaterial

func _process(delta):
	var t = mat.get_shader_parameter("shader_time") + delta
	mat.set_shader_parameter("shader_time", t)

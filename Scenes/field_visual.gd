extends ColorRect

#Reference to the shader material
var mat: ShaderMaterial

#Called when the node is added to the scene
func _ready():
	mat = material as ShaderMaterial

#Called every frame
func _process(delta):
	var t = mat.get_shader_parameter("shader_time") + delta
	mat.set_shader_parameter("shader_time", t)

extends Node
# Global and generic features for general use in the game.


# Variables
var _shaders := {}


# Public methods
# Checks if the node is at the root of the scene hierarchy.
func is_in_root(node: Node) -> bool:
	for child in node.get_tree().root.get_children():
		if child.name == node.name:
			return true

	return false


# Blinks a control when requested, such as when there is an error.
func highlight_control(
	control: Control,
	highlight_color := Color.red,
	initial_color := Color.white,
	trans_time := 0.1,
	repeat := 3
) -> void:
	var tween := control.get_tree().create_tween()

	for i in repeat:
		tween.tween_property(control, "self_modulate", highlight_color, trans_time)
		tween.tween_property(control, "self_modulate", initial_color, trans_time)


# Momentarily animates the scale of the control.
func highlight_control_scale(control: Control, duration := 0.2, size := 1.2) -> void:
	var tween := control.create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(control, "rect_scale", Vector2(size, size), duration / 2)
	tween.tween_property(control, "rect_scale", Vector2(1.0, 1.0), duration / 2)


# Register a global parameter of a shader.
func register_global_shader_param(param: String, shader_material: ShaderMaterial) -> void:
	if not _shaders.get(param.hash()):
		_shaders[param.hash()] = []

	var shaders: Array = _shaders[param.hash()]

	if not shaders.has(shader_material):
		shaders.push_back(shader_material)


# Unregister a global parameter of a shader.
func unregister_global_shader_param(param: String, shader_material: ShaderMaterial) -> void:
	if not _shaders.get(param.hash()):
		return

	var shaders: Array = _shaders[param.hash()]

	if shaders.has(shader_material):
		shaders.erase(shader_material)


# Changes the value of a global parameter of registered shaders.
func set_global_shader_param(param: String, value) -> void:
	var shaders: Array = _shaders.get(param.hash(), [])

	for shader_ in shaders:
		var shader: ShaderMaterial = shader_
		shader.set_shader_param(param, value)

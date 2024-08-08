extends Node
# Node responsible for registering global shader parameters.


# Variables
export var property_name := "player_world_position"
export(Array, ShaderMaterial) var shaders: Array = []


# Built-in overrides
# Register shaders parameters when starting scene.
func _enter_tree() -> void:
	for material in shaders:
		if not material:
			continue

		GameCore.register_global_shader_param(property_name, material)


# Unregister shaders parameters when exiting the scene.
func _exit_tree() -> void:
	for material in shaders:
		if not material:
			continue

		GameCore.unregister_global_shader_param(property_name, material)

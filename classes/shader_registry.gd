extends Node


# Variables
export var property_name := "player_world_position"
export(Array, ShaderMaterial) var shaders: Array = []


# Built-in overrides
# Registrar parâmetros de shaders ao iniciar cena.
func _enter_tree() -> void:
	for material in shaders:
		if not material:
			continue

		GameCore.register_global_shader_param(property_name, material)


# Desregistrar parâmetros de shaders ao sair da cena.
func _exit_tree() -> void:
	for material in shaders:
		if not material:
			continue

		GameCore.unregister_global_shader_param(property_name, material)

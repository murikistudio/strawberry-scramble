extends PlayerBaseComponent


# Variables
export(Array, ShaderMaterial) var shaders_to_update: Array
export(float, 0.5, 2.0, 0.01) var view_forward_multiplier := 1.5
onready var _mesh_direction: MeshInstance = player.find_node("MeshDirection")
onready var _directional_light: DirectionalLight = player.find_node("DirectionalLight")


# Built-in overrides
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_directional_light.set_as_toplevel(true)
	_mesh_direction.set_as_toplevel(true)

	for material in shaders_to_update:
		if not material:
			continue

		GameCore.register_global_shader_param("player_world_position", material)


func _process(_delta: float) -> void:
	GameCore.set_global_shader_param("player_world_position", player.global_translation)


func _physics_process(delta: float) -> void:
	if player.dead:
		return

	_directional_light.global_translation = player.global_translation

	_process_visual(delta)


# Private methods
# Atualiza as malhas visuais de acordo com o estado.
func _process_visual(_delta: float) -> void:
	var target_vec: Vector3 = player.global_translation + _get_axis_offset(player.move_weight) * view_forward_multiplier
	var interp_vec: Vector3 = lerp(player.global_translation, target_vec, 0.01)

	if player.move_weight.length() > 0.1:
		player.look_at(interp_vec, Vector3.UP)

	_mesh_direction.global_translation = target_vec


# Helper methods
# Converte o Vector2 de entrada de controle para a direção alvo em Vector3.
static func _get_axis_offset(axis_vec: Vector2) -> Vector3:
	return Vector3(-axis_vec.x, 0.0, axis_vec.y)


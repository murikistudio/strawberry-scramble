extends PlayerBaseComponent


# Variables
export(float, 0.5, 2.0, 0.01) var view_forward_multiplier := 1.5
export(float, 1.0, 20.0, 0.1) var turn_speed := 10.0
export(PackedScene) var scene_smoke: PackedScene
onready var _mesh_direction: MeshInstance = player.find_node("MeshDirection")
onready var _directional_light: DirectionalLight = player.find_node("DirectionalLight")


# Built-in overrides
func _ready() -> void:
	player.connect("smoke_spawned", self, "_on_smoke_spawned")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_directional_light.set_as_toplevel(true)
	_mesh_direction.set_as_toplevel(true)


func _process(_delta: float) -> void:
	GameCore.set_global_shader_param("player_world_position", player.global_translation)


func _physics_process(delta: float) -> void:
	if player.dead:
		return

	_directional_light.global_translation = player.global_translation

	_process_visual(delta)


# Private methods
# Atualiza as malhas visuais de acordo com o estado.
func _process_visual(delta: float) -> void:
	if player.move_weight.length() > 0.1:
		var target_rotation := lerp_angle(
			player.global_rotation.y,
			atan2(player.move_weight.x, -player.move_weight.y),
			turn_speed * delta
		)

		player.global_rotation.y = target_rotation

	var target_vec: Vector3 = player.global_translation + player.get_axis_offset(player.move_weight) * view_forward_multiplier
	_mesh_direction.global_translation = target_vec


# Event handlers
func _on_smoke_spawned() -> void:
	if not scene_smoke:
		return

	yield(get_tree(), "idle_frame")
	var smoke: Spatial = scene_smoke.instance()
	player.add_child(smoke)
	smoke.set_as_toplevel(true)
	smoke.global_translation = player.global_translation
	smoke.global_translation.y -= 0.7
	smoke.global_rotation.y = deg2rad(rand_range(0, 360))

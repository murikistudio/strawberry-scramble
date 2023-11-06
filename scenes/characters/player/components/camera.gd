extends PlayerBaseComponent
# Componente de lógica de câmera.


# Constants
const CAMERA_FOV_WEIGHT := 0.04


# Variables
onready var _camera: Camera = player.find_node("Camera")
onready var _camera_axis: Spatial = player.find_node("CameraAxis")
onready var _mesh_direction: MeshInstance = player.find_node("MeshDirection")
onready var _ray_cast_camera: RayCast = player.find_node("RayCastCamera")
onready var _camera_focus: Spatial = null
onready var _camera_fov_default: float = _camera.fov
onready var _camera_fov_far: float = _camera_fov_default + 25.0
onready var _shake_obj


# Built-in overrides
func _ready() -> void:
	GameEvents.connect("player_request_camera_focus", self, "_on_player_request_camera_focus")
	_ray_cast_camera.set_as_toplevel(true)
	_camera_axis.set_as_toplevel(true)


func _physics_process(_delta: float) -> void:
	_set_objects_from_meta()
	_process_fov()
	_process_shake()
	_process_focus()
	_process_collision()


# Private methods
# Define os valores de objetos guardados no meta da câmera.
func _set_objects_from_meta() -> void:
	_shake_obj = _camera.get_meta("shake", false)

	if _shake_obj and not is_instance_valid(_shake_obj):
		_shake_obj = null


# Processa o campo de visão quando a pedra gigante estiver rolando.
func _process_fov() -> void:
	if _shake_obj:
		_camera.fov = lerp(_camera.fov, _camera_fov_far, CAMERA_FOV_WEIGHT)
	else:
		_camera.fov = lerp(_camera.fov, _camera_fov_default, CAMERA_FOV_WEIGHT)


# Processa a tremulação da câmera quando a pedra gigante estiver rolando.
func _process_shake() -> void:
	if _shake_obj:
		var value := 0.2 / player.global_translation.distance_to(_shake_obj.global_translation)
		_camera.h_offset = rand_range(-value, value)
		_camera.v_offset = rand_range(-value, value)
	else:
		_camera.h_offset = 0.0
		_camera.v_offset = 0.0


# Processa a movimentação e suavização da câmera.
func _process_focus() -> void:
	if not _camera_focus:
		_camera_focus = _mesh_direction

	_camera_axis.global_translation = _camera_axis.global_translation.linear_interpolate(
		_camera_focus.global_translation, 0.1
	)


# Processa a colisão da câmera com o cenário e obstáculos.
func _process_collision() -> void:
	_ray_cast_camera.global_translation = player.global_translation + Vector3(0, 0.2, 0)

	if not _ray_cast_camera.is_colliding() or player.state_manager.current_state == player.state_stop:
		_camera_axis.rotation = _camera_axis.rotation.linear_interpolate(
			Vector3(deg2rad(-45), 0, 0), 0.1
		)
		return

	var camera_obstacle: Node = _ray_cast_camera.get_collider()
	var obstacle_name := camera_obstacle.name.to_lower()

	if "home" in obstacle_name or "house" in obstacle_name:
		_camera_axis.rotation = _camera_axis.rotation.linear_interpolate(
			Vector3(deg2rad(0), 0, 0), 0.1
		)


# Event handlers
# Alterar objeto de foco da câmera.
func _on_player_request_camera_focus(target: Spatial) -> void:
	if not target:
		_camera_focus = null
	else:
		_camera_focus = target

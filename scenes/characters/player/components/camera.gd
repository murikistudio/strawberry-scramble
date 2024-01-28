extends PlayerBaseComponent
# Componente de lógica de câmera.


# Enums
enum ControllerLook {
	MOUSE,
	JOYPAD,
}


# Constants
const CAMERA_FOV_WEIGHT := 0.04


# Variables
export(int, -1, 1, 2) var look_invert_x := 1
export(int, -1, 1, 2) var look_invert_y := -1
export(float, 0.0, 200.0, 0.1) var look_sensitivity := 80.0
export(float, -90.0, 90.0, 0.1) var camera_min_angle := 10.0
export(float, -90.0, 90.0, 0.1) var camera_max_angle := 80.0
var _controller: int = ControllerLook.MOUSE
var _can_control := true
onready var _camera: Camera = player.find_node("Camera")
onready var _camera_axis: Spatial = player.find_node("CameraAxis")
onready var _camera_smooth: Spatial = player.find_node("CameraSmooth")
onready var _camera_origin: Spatial = player.find_node("CameraOrigin")
onready var _mesh_direction: MeshInstance = player.find_node("MeshDirection")
onready var _ray_cast_camera: RayCast = player.find_node("RayCastCamera")
onready var _camera_focus: Spatial = null
onready var _camera_fov_default: float = _camera.fov
onready var _camera_fov_far: float = _camera_fov_default + 25.0
onready var _shake_obj


# Built-in overrides
func _ready() -> void:
	GameEvents.connect("player_request_camera_focus", self, "_on_player_request_camera_focus")
	GameEvents.connect("level_complete", self, "_on_level_complete")
	_camera_axis.set_as_toplevel(true)
	_camera_smooth.set_as_toplevel(true)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadMotion and event.axis_value > 0.1:
		_controller = ControllerLook.JOYPAD

	elif event is InputEventMouseMotion and event.speed.length() > 1:
		_controller = ControllerLook.MOUSE


func _physics_process(_delta: float) -> void:
	_set_objects_from_meta()
	_process_fov()
	_process_shake()
	_process_focus()
	_process_movement(_delta)
	#_process_collision()


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
		_camera_focus = player


# Processa a movimentação e suavização da câmera.
func _process_movement(delta: float) -> void:
	var look_axis = Input.get_vector("look_left", "look_right", "look_down", "look_up")

	var mouse_pos := (get_viewport().size / 2).floor()

	if _can_control:
		get_viewport().warp_mouse(mouse_pos)

	var mouse_offset := get_viewport().get_mouse_position() / mouse_pos - Vector2(1, 1) \
		if not look_axis.length() else look_axis * 0.04 * Vector2(look_invert_x, look_invert_y)

	mouse_offset = mouse_offset.snapped(Vector2(0.01, 0.01)) if _can_control else Vector2.ZERO

	var mouse_rotation_x := -mouse_offset.x * delta * look_sensitivity
	var mouse_rotation_y := mouse_offset.y * delta * look_sensitivity
	var target_vec: Vector3 = player.global_translation + player.get_axis_offset(player.move_weight)

	_camera_axis.global_translation = lerp(_camera_focus.global_translation, target_vec, 0.1)
	_camera_axis.rotation.y += mouse_rotation_x

	_camera_axis.rotation.x = clamp(
		_camera_axis.rotation.x + mouse_rotation_y,
		deg2rad(camera_min_angle), deg2rad(camera_max_angle)
	)

	if player.move_axis.length() and _controller == ControllerLook.JOYPAD:
		_camera_axis.rotation.y -= player.input_axis.x * 1.5 * delta

	_camera_smooth.global_transform = _camera_smooth.global_transform.interpolate_with(
		_camera_axis.global_transform, 0.2
	)


# Processa a colisão da câmera com o cenário e obstáculos.
func _process_collision() -> void:
	_ray_cast_camera.cast_to.z = -_ray_cast_camera.global_translation.distance_to(_camera_origin.global_translation)
	_camera.global_translation = _ray_cast_camera.get_collision_point() \
		if _ray_cast_camera.is_colliding() \
		else _camera_origin.global_translation

	_camera.translation.z += 0.2


# Event handlers
# Alterar objeto de foco da câmera.
func _on_player_request_camera_focus(target: Spatial) -> void:
	if not target:
		_camera_focus = null
		player.state_manager.transition_to(player.state_idle)
	else:
		_camera_focus = target
		player.state_manager.transition_to(player.state_stop)


func _on_level_complete() -> void:
	_can_control = false

extends KinematicBody
# Behavior of the enemy bee.


const GRAVITY_FORCE := 4.0


# Enums
enum State {
	IDLE,
	CHASE,
	RETURN,
}


# Variables
export(float, 0.1, 10.0, 0.01) var move_speed := 1.8
export(float, 0.1, 10.0, 0.01) var turn_speed := 4.0
export(float, 0.1, 20.0, 0.01) var activation_distance := 5.0
var dead := false
var _player: Spatial
var _state: int = State.IDLE
var _gravity := 0.0
onready var _anim_player: AnimationPlayer = find_node("AnimationPlayer")
onready var _initial_position := global_translation


# Built-in overrides
func _init() -> void:
	GameEvents.connect("player_emitted", self, "_on_player_emitted")
	GameEvents.connect("enemy_killed", self, "_on_enemy_killed")


func _physics_process(delta: float) -> void:
	if not _player:
		return

	if dead:
		_process_dead(delta)
		return

	var current_height := stepify(global_translation.y, 0.1)
	var initial_height := stepify(_initial_position.y, 0.1)

	if current_height > initial_height:
		_gravity -= GRAVITY_FORCE * delta
	elif current_height < initial_height:
		_gravity += GRAVITY_FORCE * delta
	else:
		_gravity = 0.0

	_gravity = clamp(_gravity, -1, 1)

	match _state:
		State.IDLE:
			_process_idle(delta)
		State.CHASE:
			_process_chase(delta)
		State.RETURN:
			_process_return(delta)


# Private methods
func _process_dead(delta: float) -> void:
	if scale.x <= 0.0:
		queue_free()
		return

	var scale_factor := 0.05
	scale -= Vector3(scale_factor, scale_factor, scale_factor)
	rotate_y(30.0 * delta)


# Enemy stopped in the starting position waiting to chase the player.
func _process_idle(delta: float) -> void:
	var distance := _get_distance_to_player()

	if distance <= activation_distance and not _player.dead:
		_state = State.CHASE
		return

	_anim_player.play("idle_loop", 0.2)
	_look_at_position(_player.global_translation, delta)


# Enemy chasing the player and may return to the starting position if he moves away from him.
func _process_chase(delta: float) -> void:
	var distance := _get_distance_to_player()

	if distance > activation_distance or _player.dead:
		_state = State.RETURN
		return

	_anim_player.play("run_loop", 0.2)
	_move_to_position(_player.global_translation, delta)


# Enemy returning to the starting position and can re-pursue the player if he approaches.
func _process_return(delta: float) -> void:
	var distance := _get_distance_to_player()

	if distance <= activation_distance and not _player.dead:
		_state = State.CHASE
		return

	var distance_to_initial_position := _get_distance_to_initial_position()

	if distance_to_initial_position <= 0.2:
		_state = State.IDLE
		return

	_anim_player.play("run_loop", 0.2)
	_move_to_position(_initial_position, delta)


# Move to the specified position.
func _move_to_position(target_position: Vector3, delta: float) -> void:
	_look_at_position(target_position, delta)
	var move_vec := (target_position - global_translation).normalized()
	move_vec.y = _gravity
	move_and_slide(move_vec * move_speed, Vector3.UP)


# Look at the specified position.
func _look_at_position(target_position: Vector3, delta: float) -> void:
	var target_vec := target_position - global_translation

	if not target_vec.length():
		return

	var target_rotation := lerp_angle(
		global_rotation.y,
		atan2(target_vec.x, target_vec.z),
		turn_speed * delta
	)
	global_rotation.y = target_rotation


# Return the distance to the player.
func _get_distance_to_player() -> float:
	return global_translation.distance_to(_player.global_translation)


# Return the distance to the initial position.
func _get_distance_to_initial_position() -> float:
	var initial_pos_2d := Vector2(_initial_position.x, _initial_position.z)
	var current_pos_2d := Vector2(global_translation.x, global_translation.z)
	return current_pos_2d.distance_to(initial_pos_2d)


# Event handlers
# Store player reference at start.
func _on_player_emitted(player: Spatial) -> void:
	_player = player


# Kill current enemy.
func _on_enemy_killed(enemy: Spatial) -> void:
	if dead or enemy != self:
		return

	dead = true

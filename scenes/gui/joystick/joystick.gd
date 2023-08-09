extends MarginContainer


# Variables
export var enabled := false

var _stick_left_position := Vector2.ZERO
var _stick_left_pressing := false
var _stick_left_axis_movement := Vector2.ZERO

onready var _texture_rect_stick_left_back: TextureRect = find_node("TextureRectStickLeftBack")
onready var _stick_left: Control = find_node("StickLeft")
onready var _texture_button_jump: TextureButton = find_node("TextureButtonJump")
onready var _texture_button_pause: TextureButton = find_node("TextureButtonPause")


func _ready() -> void:
	if OS.get_name() == "Android":
		visible = true
		return

	visible = enabled


func _process(_delta: float) -> void:
	if not enabled:
		return

	_center_pivot(_texture_button_jump)
	_center_pivot(_texture_button_pause)

	if _stick_left_pressing:
		_stick_left.rect_position = _stick_left_position
	else:
		_stick_left.rect_position = _texture_rect_stick_left_back.rect_size / 2

	if _stick_left_pressing:
		_stick_left_axis_movement = _stick_left_position / _texture_rect_stick_left_back.rect_size
		_stick_left_axis_movement.x = (clamp(_stick_left_axis_movement.x, 0.0, 1.0) - 0.5) * 2.0
		_stick_left_axis_movement.y = (clamp(-(_stick_left_axis_movement.y - 1.0), 0.0, 1.0) - 0.5) * 2.0

		if stepify(_stick_left_axis_movement.x, 0.1):
			_update_input_action(
				"move_left" if _stick_left_axis_movement.x < 0 else "move_right",
				abs(_stick_left_axis_movement.x)
			)

		if stepify(_stick_left_axis_movement.y, 0.1):
			_update_input_action(
				"move_down" if _stick_left_axis_movement.y < 0 else "move_up",
				abs(_stick_left_axis_movement.y)
			)


func _center_pivot(control: Control) -> void:
	control.rect_pivot_offset = control.rect_size / 2


func _update_input_action(action: String, strength: float) -> void:
	if strength > InputMap.action_get_deadzone(action):
		Input.action_press(action, strength)

	elif Input.is_action_pressed(action):
		Input.action_release(action)


func _on_TextureRectStickLeftBack_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		_stick_left_position = event.position

	if event is InputEventScreenTouch:
		_stick_left_pressing = event.is_pressed()

		if not event.is_pressed():
			for input_name in ["move_left", "move_right", "move_up", "move_down"]:
				_update_input_action(input_name, 0.0)


func _on_TextureButtonJump_button_down() -> void:
	_update_input_action("jump", 1.0)
	GameCore.highlight_control_scale(_texture_button_jump, 0.1)


func _on_TextureButtonJump_button_up() -> void:
	_update_input_action("jump", 0.0)


func _on_TextureButtonPause_button_down() -> void:
	_update_input_action("pause", 1.0)
	GameCore.highlight_control_scale(_texture_button_pause, 0.1)


func _on_TextureButtonPause_button_up() -> void:
	_update_input_action("pause", 0.0)


func _on_TextureButtonJump_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_on_TextureButtonJump_button_down()
		else:
			_on_TextureButtonJump_button_up()

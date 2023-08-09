extends MarginContainer


# Variables
export var enabled := false

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


func _center_pivot(control: Control) -> void:
	control.rect_pivot_offset = control.rect_size / 2


func _update_input_action(action: String, strength: float) -> void:
	if strength > InputMap.action_get_deadzone(action):
		Input.action_press(action, strength)

	elif Input.is_action_pressed(action):
		Input.action_release(action)


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

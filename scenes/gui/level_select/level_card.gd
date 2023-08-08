extends MarginContainer


# Variables
export var level_path := ""
export var focus_button := false

onready var _label_level_name: Label = find_node("LabelLevelName")
onready var _texture_rect_thumbnail: TextureRect = find_node("TextureRectThumbnail")
onready var _button_level: Button = find_node("ButtonLevel")


# Built-in overrides
func _ready() -> void:
	var parts := level_path.split("/", false)

	if not parts.size():
		return

	var file_name: String = parts[-1]
	parts = file_name.split(".", false)

	if parts.size():
		file_name = tr(parts[0])

	_label_level_name.text = file_name

	if focus_button:
		yield(GuiTransitions, "show_completed")
		_button_level.grab_focus()


# Event handlers
func _on_ButtonLevel_pressed() -> void:
	if not level_path:
		return

	GameTransition.change_scene_to(level_path)

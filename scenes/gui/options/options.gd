extends Control


# Signals
signal options_exited


# Variables
onready var _button_language: Button = find_node("ButtonLanguage")
onready var _button_fullscreen: Button = find_node("ButtonFullscreen")
onready var _button_shadows: Button = find_node("ButtonShadows")
onready var _slider_sfx: Slider = find_node("SliderSfx")
onready var _slider_bgm: Slider = find_node("SliderBgm")
onready var _background: CanvasLayer = find_node("Background")


# Built-in overrides
func _ready() -> void:
	GuiTransitions.connect("show_completed", self, "_on_show_completed")
	_background.visible = GameCore.is_in_root(self)
	_update_gui()


# Private methods
func _update_gui() -> void:
	GameConfig.apply_config()
	_button_language.text = tr(GameConfig.language)
	_button_fullscreen.text = tr("Enabled") if GameConfig.fullscreen else tr("Disabled")
	_button_shadows.text = tr("Disabled") if GameConfig.shadows == 0 \
		else tr("Simple") if GameConfig.shadows == 1 \
		else tr("Advanced")

	_slider_sfx.value = GameConfig.sfx
	_slider_bgm.value = GameConfig.bgm


# Event handlers
func _on_show_completed() -> void:
	if not GuiTransitions.is_shown(name):
		return

	_button_language.grab_focus()


func _on_ButtonBack_pressed() -> void:
	if GameCore.is_in_root(self):
		GameTransition.change_scene_to(DatabaseScenes.GUI_MENU)
	else:
		emit_signal("options_exited")


func _on_ButtonLanguage_pressed() -> void:
	var locales := TranslationServer.get_loaded_locales()
	GameConfig.language = locales[wrapi(
		locales.find(GameConfig.language) + 1,
		0, locales.size()
	)]
	GameConfig.save_config()
	_update_gui()


func _on_ButtonFullscreen_pressed() -> void:
	GameConfig.fullscreen = not GameConfig.fullscreen
	GameConfig.save_config()
	_update_gui()


func _on_ButtonShadows_pressed() -> void:
	GameConfig.shadows = wrapi(GameConfig.shadows + 1, 0, 3)
	GameConfig.save_config()
	_update_gui()


func _on_SliderSfx_value_changed(value: float) -> void:
	GameConfig.sfx = value
	GameConfig.apply_config(false, true, false)


func _on_SliderSfx_drag_ended(value_changed: bool) -> void:
	if not value_changed:
		return

	GameConfig.save_config()
	_update_gui()


func _on_SliderBgm_value_changed(value: float) -> void:
	GameConfig.bgm = value
	GameConfig.apply_config(false, true, false)


func _on_SliderBgm_drag_ended(value_changed: bool) -> void:
	if not value_changed:
		return

	GameConfig.save_config()
	_update_gui()

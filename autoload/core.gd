extends Node


# Signals
signal config_applied


# Classes
class Config extends Reference:
	const SECTION := "config"
	const SAVE_PATH := "user://config.cfg"
	const SHADOWS_DISABLED := 0
	const SHADOWS_SIMPLE := 1
	const SHADOWS_ADVANCED := 2
	const CONFIG_KEYS := ["language", "fullscreen", "shadows", "sfx", "bgm"]

	var language := "en"
	var fullscreen := false
	var shadows := SHADOWS_DISABLED
	var sfx := 1.0
	var bgm := 1.0

	var _core: Node = null


	func _init(core: Node = null) -> void:
		_core = core

		var loaded := load_config()
		apply_config()

		if loaded:
			return

		save_config()


	func save_config() -> void:
		var config_file := ConfigFile.new()

		for key in CONFIG_KEYS:
			config_file.set_value(SECTION, key, get(key))

		config_file.save(SAVE_PATH)
		prints("Saved config to:", SAVE_PATH)


	func load_config() -> bool:
		var config_file := ConfigFile.new()
		var err := config_file.load(SAVE_PATH)

		if err != OK:
			prints("Cannot load config from:", SAVE_PATH)
			return false

		for key in CONFIG_KEYS:
			if not config_file.has_section_key(SECTION, key):
				continue
			set(key, config_file.get_value(SECTION, key))

		prints("Loaded config from:", SAVE_PATH)
		return true


	func apply_config(video := true, audio := true, locale := true) -> void:
		if video:
			OS.window_fullscreen = fullscreen
			ProjectSettings.set("rendering/quality/shadows/filter_mode", shadows)
			ProjectSettings.set("rendering/quality/shadows/filter_mode.mobile", shadows)

		if audio:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear2db(sfx))
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), linear2db(bgm))

		if locale:
			TranslationServer.set_locale(language)

		if _core and _core.has_signal("config_applied"):
			_core.emit_signal("config_applied")


# Variables
var config := Config.new(self)


# Transiciona suavemente para uma nova cena no jogo.
func change_scene_to(scene, unpause := true) -> void:
	if not scene:
		push_warning("No scene passed to change_scene_to!")
		return

	if typeof(scene) == TYPE_STRING:
		scene = load(scene)

	GuiTransitions.hide()
	GameOverlay.show()
	yield(GameOverlay, "show_completed")

	if unpause:
		get_tree().paused = false

	get_tree().change_scene_to(scene)
	GameOverlay.hide()


# Verifica se o node está na raiz da hierarquia de cena.
func is_in_root(node: Node) -> bool:
	for child in node.get_tree().root.get_children():
		if child.name == node.name:
			return true

	return false


# Retorna um valor da configuração.
func get_config(key: String):
	return config.get(key) if key in config else null

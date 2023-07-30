extends Node
# Gerenciador de configurações de usuário do jogo.


# Signals
signal config_applied


# Constants
const SECTION := "config"
const SAVE_PATH := "user://config.cfg"
const SHADOWS_DISABLED := 0
const SHADOWS_SIMPLE := 1
const SHADOWS_ADVANCED := 2
const CONFIG_KEYS := ["language", "fullscreen", "shadows", "sfx", "bgm"]


# Variables
var language := "en"
var fullscreen := false
var shadows := SHADOWS_DISABLED
var sfx := 1.0
var bgm := 1.0


func _ready() -> void:
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

	emit_signal("config_applied")

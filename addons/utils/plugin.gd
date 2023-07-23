tool
extends EditorPlugin


const DEFAULT_CONFIG := [
	{
		"name": "utils/button_highlighter/click_sound/file",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.wav,*.ogg,*.mp3",
	},
	{
		"name": "utils/button_highlighter/click_sound/bus",
		"type": TYPE_STRING,
		"default": "Master",
	},
	{
		"name": "utils/config_enabler/singleton/name",
		"type": TYPE_STRING,
	},
	{
		"name": "utils/config_enabler/singleton/getter",
		"type": TYPE_STRING,
	},
	{
		"name": "utils/config_enabler/singleton/signal",
		"type": TYPE_STRING,
	},
]


func enable_plugin() -> void:
	for config in DEFAULT_CONFIG:
		if not ProjectSettings.has_setting(config["name"]):
			ProjectSettings.set_setting(config["name"], config.get("default", ""))

		ProjectSettings.add_property_info(config)


func disable_plugin() -> void:
	for config in DEFAULT_CONFIG:
		if not ProjectSettings.has_setting(config["name"]):
			continue

		ProjectSettings.set_setting(config["name"], null)

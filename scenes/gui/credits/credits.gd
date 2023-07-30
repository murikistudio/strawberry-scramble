extends Control
# Tela de créditos do jogo.


# Variables
onready var _label_version: Label = find_node("LabelVersion")
onready var _label_studio: Label = find_node("LabelStudio")
onready var _button_back: BaseButton = find_node("ButtonBack")


# Built-in overrides
func _ready() -> void:
	_button_back.grab_focus()
	_update_labels()


# Private methods
# Atualizar labels dinâmicas.
func _update_labels() -> void:
	_label_version.text = tr("{name} v{version}").format({
		"name": ProjectSettings.get_setting("application/config/name"),
		"version": ProjectSettings.get_setting("application/config/version"),
	})

	_label_studio.text = tr("{author}, {year}").format({
		"author": ProjectSettings.get_setting("application/config/author"),
		"year": Time.get_datetime_dict_from_system()["year"],
	})


# Event handlers
# Ao pressionar botão de voltar.
func _on_ButtonBack_pressed() -> void:
	GuiTransitions.hide()
	GameTransition.change_scene_to(DatabaseScenes.GUI_MENU)

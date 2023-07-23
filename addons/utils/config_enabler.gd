class_name ConfigEnabler, "res://addons/utils/icons/config_enabler.png"
extends Node
# Node utilitário que habilita ou desabilita uma propriedade do pai de acordo
# com uma configuração de usuário.


# Enums
enum ConversionType {
	NO_CONVERSION,
	BOOL,
	INT,
	FLOAT,
	STRING,
}


# Constants
const SETTING_BASE := "utils/config_enabler/"
const SETTING_SINGLETON_NAME := SETTING_BASE + "singleton/name"
const SETTING_SINGLETON_SIGNAL := SETTING_BASE + "singleton/signal"
const SETTING_SINGLETON_GETTER := SETTING_BASE + "singleton/getter"


# Variables
export var config_key := ""
export var target_key := ""
export(ConversionType) var convert_to := ConversionType.NO_CONVERSION

onready var _config_singleton: Object
onready var _config_getter: String
onready var _config_valid := false


# Built-in overrides
func _ready() -> void:
	_get_config_values()
	apply_value()


# Public methods
# Aplica a configuração especificada no node pai.
func apply_value():
	if not _config_valid:
		push_warning("Invalid config set in project settings: " + SETTING_BASE)
		return

	var parent: Node = get_parent()

	if target_key in parent:
		var value = _get_value()
		parent.set(target_key, value)


# Private methods
func _get_config_values() -> void:
	var config_singleton_name: String = ProjectSettings.get_setting(SETTING_SINGLETON_NAME)

	if not config_singleton_name or not get_tree().root.has_node(config_singleton_name):
		push_warning("Invalid singleton set in project settings: " + SETTING_SINGLETON_NAME)
		return

	_config_singleton = get_tree().root.get_node(config_singleton_name)
	_config_getter = ProjectSettings.get_setting(SETTING_SINGLETON_GETTER)

	if not _config_getter or not _config_singleton.has_method(_config_getter):
		push_warning("Invalid getter set in project settings: " + SETTING_SINGLETON_GETTER)
		return

	_config_valid = true

	var setting_signal: String = ProjectSettings.get_setting(SETTING_SINGLETON_SIGNAL)

	if not setting_signal or not _config_singleton.has_signal(setting_signal):
		push_warning("Invalid signal set in project settings: " + SETTING_SINGLETON_SIGNAL)
		return

	_config_singleton.connect(setting_signal, self, "apply_value")


# Obtém e converte o valor da configuração especificada.
func _get_value():
	var value = _config_singleton.call(_config_getter, config_key)

	match convert_to:
		ConversionType.BOOL:
			value = bool(value)
		ConversionType.INT:
			value = int(value)
		ConversionType.FLOAT:
			value = float(value)
		ConversionType.STRING:
			value = str(value)

	return value

class_name EditorVisibility, "res://addons/utils/icons/editor_visibility.png"
extends Node
# Node utilitário responsável por tornar um node pai visível ao iniciar o jogo.


# Variables
export var visible := true


# Built-in overrides
func _ready() -> void:
	var parent := get_parent()

	if not parent or not "visible" in parent:
		return

	parent.visible = visible

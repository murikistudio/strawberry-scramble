class_name EditorVisibility, "res://addons/utils/icons/editor_visibility.png"
extends Node
# Node utilitário responsável por tornar um node pai visível ao iniciar o jogo.


# Variables
export var visible := true
export var delete_in_game := false


# Built-in overrides
func _ready() -> void:
	var parent := get_parent()

	if not parent:
		return

	if delete_in_game:
		parent.queue_free()
		return

	if not "visible" in parent:
		return

	parent.visible = visible

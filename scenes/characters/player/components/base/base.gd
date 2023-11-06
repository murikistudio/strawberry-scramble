extends BaseComponent
class_name PlayerBaseComponent


# Variables
var player: Player


# Setters
# Override do setter de object. Atribui o player da classe.
func _set_object(value: Node) -> void:
	._set_object(value)
	player = value

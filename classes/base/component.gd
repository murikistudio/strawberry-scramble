extends Node
class_name BaseComponent
# Base class for components in the object.


# Variables
var object: Node setget _set_object


# Setters
func _set_object(value: Node) -> void:
	object = value

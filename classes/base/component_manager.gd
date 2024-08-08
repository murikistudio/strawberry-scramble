extends Node
class_name BaseComponentManager
# Base class for component managers, setting the owner object on children.


# Variables
export(NodePath) var owner_object: NodePath
var object: Node


# Built-in overrides
func _init() -> void:
	connect("child_entered_tree", self, "_on_child_entered_tree")


func _on_child_entered_tree(node: Node) -> void:
	_set_owner_object(node)


# Private methods
# Set the owner object on the child node.
func _set_owner_object(node: Node = null) -> void:
	if not owner_object:
		push_warning("You must set owner_object")
		return

	if not object:
		object = get_node(owner_object)

	if node:
		node.object = object

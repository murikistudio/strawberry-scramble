extends Node
class_name BaseState
# Base class for states in the state machine.


# Variables
var object: Node setget _set_object


# Setters
func _set_object(value: Node) -> void:
	object = value


# Virtual methods
# Executed upon entering the state.
func enter() -> void:
	pass


# Executed when exiting the state.
func exit() -> void:
	pass


# Executed in each input of the user.
func input(_event: InputEvent) -> BaseState:
	return null


# Executed in each unhandled input of the user.
func unhandled_input(_event: InputEvent) -> BaseState:
	return null


# Executed in each frame of the game.
func process(_delta: float) -> BaseState:
	return null


# Executed in each frame in sync with the physics of the game.
func physics_process(_delta: float) -> BaseState:
	return null


# Returns the state with the given node path.
func get_state(node: NodePath) -> BaseState:
	if not node:
		push_warning("Node path not set at state: " + name)
		return null

	return get_node(node) as BaseState

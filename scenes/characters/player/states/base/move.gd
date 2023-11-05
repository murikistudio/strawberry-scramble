extends PlayerBaseState
class_name PlayerStateMove
# Estado base de movimentação do jogador, detectando controles.


# Variables
onready var _camera_axis: Spatial = player.find_node("CameraAxis")


# State overrides
func process(_delta: float) -> BaseState:
	var input_vector := Input.get_vector(
		"move_left", "move_right",
		"move_down", "move_up"
	)

	player.move_axis = input_vector.rotated(_camera_axis.global_rotation.y)

	return null

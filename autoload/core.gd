extends Node
# Funcionalidades globais e genéricas para uso geral no jogo.


# Public methods
# Verifica se o node está na raiz da hierarquia de cena.
func is_in_root(node: Node) -> bool:
	for child in node.get_tree().root.get_children():
		if child.name == node.name:
			return true

	return false


func highlight_control(
	control: Control,
	highlight_color := Color.red,
	initial_color := Color.white,
	trans_time := 0.1,
	repeat := 3
) -> void:
	var tween := control.get_tree().create_tween()

	for i in repeat:
		tween.tween_property(control, "self_modulate", highlight_color, trans_time)
		tween.tween_property(control, "self_modulate", initial_color, trans_time)

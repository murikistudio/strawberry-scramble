extends Node
# Funcionalidades globais e genéricas para uso geral no jogo.


# Public methods
# Verifica se o node está na raiz da hierarquia de cena.
func is_in_root(node: Node) -> bool:
	for child in node.get_tree().root.get_children():
		if child.name == node.name:
			return true

	return false

class_name PlatformVisibility, "res://addons/utils/icons/platform_visibility.png"
extends Node
# Node utilitário responsável por mostrar ou esconder um controle de
# interface de usuário pai de acordo com a plataforma atual.


# Enums
enum Platforms {
	ANDROID = 1,
	IOS = 2,
	HTML5 = 4,
	OSX = 8,
	SERVER = 16,
	WINDOWS = 32,
	UWP = 64,
	X11 = 128,
}


# Variables
export var visible := false
export(int, FLAGS,
	"Android",
	"iOS",
	"HTML5",
	"OSX",
	"Server",
	"Windows",
	"UWP",
	"X11"
) var platforms

var _current_platform: int = Platforms.get(OS.get_name().to_upper())


# Built-in overrides
func _ready() -> void:
	update_visibility()


# Public methods
# Atualizar visibilidade do controle.
func update_visibility() -> void:
	var cur_parent := get_parent()

	if not cur_parent or not "visible" in cur_parent:
		return

	# Verificar se a flag da plataforma atual está ativada nas plataformas
	if platforms & _current_platform:
		cur_parent.visible = visible

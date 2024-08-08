class_name PlatformVisibility, "res://addons/utils/icons/platform_visibility.png"
extends Node
# Utility Node responsible for showing or hiding a parent user interface
# control according to the current platform.


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
# Update control visibility.
func update_visibility() -> void:
	var cur_parent := get_parent()

	if not cur_parent or not "visible" in cur_parent:
		return

	# Check that the current platform flag is activated on platforms
	if platforms & _current_platform:
		cur_parent.visible = visible

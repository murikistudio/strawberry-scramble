class_name ButtonHighlighter, "res://addons/utils/icons/button_highlighter.svg"
extends Node
# Node utilitário que altera o visual do pai quando este for pressionado.
#
# Este node reproduz um som e altera o brilho do pai através de modulate
# quando este for clicado.
# Ele também possui animações de brilho, escala e rotação.


# Constants
const SETTING_CLICK_SOUND := "utils/button_highlighter/click_sound/file"
const SETTING_CLICK_SOUND_BUS := "utils/button_highlighter/click_sound/bus"


# Variables
export var change_brightness := true
export var click_sound := true
export var mouse_focus_grab := true
export var mouse_focus_release := false
export(float, 0.0, 1.0, 0.01) var normal_brightness := 1.0
export(float, 0.0, 1.0, 0.01) var pressed_brightness := 0.85
export var anim_duration := 0.6
export var anim_brightness := false setget _set_anim_brightness
export var anim_brightness_value := 1.25
export var anim_rotation := false setget _set_anim_rotation
export var anim_rotation_value := 5.0
export var anim_scale := false setget _set_anim_scale
export var anim_scale_value := 1.05

onready var _parent := get_parent() as Control
onready var _click_sound := _get_click_sound()
onready var _click_sound_bus := _get_click_sound_bus()
onready var _initial_brightness := 1.0
onready var _initial_scale := Vector2(1.0, 1.0)
onready var _initial_rotation := 0.0
onready var _anim_trans := Tween.TRANS_QUAD


# Built-in overrides
func _ready() -> void:
	if not _parent:
		return

	_connect_signals()
	_set_brightness(normal_brightness)


# Private methods
# Setter da propriedade anim_brightness.
func _set_anim_brightness(value: bool) -> void:
	anim_brightness = value

	if _parent:
		_animate_brightness()


# Setter da propriedade anim_rotation.
func _set_anim_rotation(value: bool) -> void:
	anim_rotation = value

	if _parent:
		_animate_rotation()


# Setter da propriedade anim_scale.
func _set_anim_scale(value: bool) -> void:
	anim_scale = value

	if _parent:
		_animate_scale()


# Atribuir valores iniciais de variáveis de animação.
func _set_initial_values() -> void:
	anim_brightness = _parent.self_modulate.a
	_initial_scale = _parent.rect_scale
	_initial_rotation = _parent.rect_rotation


# Retornar som a ser reproduzido ao clicar no botão.
func _get_click_sound() -> AudioStream:
	var setting_click_sound: String = ProjectSettings.get_setting(SETTING_CLICK_SOUND)

	if ResourceLoader.exists(setting_click_sound):
		return ResourceLoader.load(setting_click_sound) as AudioStream

	return null


# Retornar bus de áudio onde reproduzir som do clique do botão.
func _get_click_sound_bus() -> String:
	var bus: String = ProjectSettings.get_setting(SETTING_CLICK_SOUND_BUS)
	return bus if bus else "Master"


# Criar player de áudio e tocar som de click.
func _play_click_sound() -> void:
	if not _click_sound or not click_sound:
		return

	var audio_player := AudioStreamPlayer.new()
	audio_player.stream = _click_sound
	audio_player.bus = _click_sound_bus
	audio_player.connect("finished", self, "_on_audio_player_finished", [audio_player])
	audio_player.play()
	add_child(audio_player)


# Executar animação de modulação de brilho.
func _animate_brightness() -> void:
	if not anim_brightness:
		return

	var tween := get_tree().create_tween()
	var prop := "self_modulate:v"
	tween.bind_node(self)
	tween.set_trans(_anim_trans)
	tween.tween_property(_parent, prop, anim_brightness_value, anim_duration)
	tween.tween_property(_parent, prop, _initial_brightness, anim_duration)
	tween.connect("finished", self, "_on_tween_finished", ["_animate_brightness"])


# Executar animação de modulação de rotação.
func _animate_rotation() -> void:
	if not anim_rotation:
		return

	var prop := "rect_rotation"
	var tween := get_tree().create_tween()
	tween.bind_node(self)
	_center_pivot()
	tween.set_trans(_anim_trans)
	tween.tween_property(_parent, prop, anim_rotation_value, anim_duration / 2)
	tween.tween_property(_parent, prop, -anim_rotation_value, anim_duration)
	tween.tween_property(_parent, prop, _initial_rotation, anim_duration / 2)
	tween.connect("finished", self, "_on_tween_finished", ["_animate_rotation"])


# Executar animação de modulação de escala.
func _animate_scale() -> void:
	if not anim_scale:
		return

	var prop := "rect_scale"
	var tween := get_tree().create_tween()
	tween.bind_node(self)
	_center_pivot()
	tween.set_trans(_anim_trans)
	tween.tween_property(_parent, prop, _initial_scale * anim_scale_value, anim_duration)
	tween.tween_property(_parent, prop, _initial_scale, anim_duration)
	tween.connect("finished", self, "_on_tween_finished", ["_animate_scale"])


# Conectar sinais de reação do node pai.
func _connect_signals() -> void:
	if _parent.has_signal("mouse_entered"):
		_parent.connect("mouse_entered", self, "_on_parent_mouse_entered")

	if _parent.has_signal("mouse_exited"):
		_parent.connect("mouse_exited", self, "_on_parent_mouse_exited")

	if _parent.has_signal("button_down"):
		_parent.connect("button_down", self, "_on_parent_button_down")

	if _parent.has_signal("button_up"):
		_parent.connect("button_up", self, "_on_parent_button_up")

	if _parent.has_signal("toggled"):
		_parent.connect("toggled", self, "_on_parent_button_up")

	if _parent.has_signal("drag_started"):
		_parent.connect("drag_started", self, "_on_parent_button_up")

	if _parent.has_signal("drag_ended"):
		_parent.connect("drag_ended", self, "_on_parent_button_up")

	get_tree().connect("idle_frame", self, "_on_idle_frame", [], Node.CONNECT_ONESHOT)


# Alterar brilho do node pai.
func _set_brightness(value: float) -> void:
	if change_brightness:
		_parent.modulate.v = value


# Centraliza o pivô do node pai.
func _center_pivot() -> void:
	if not _parent:
		return

	_parent.rect_pivot_offset = _parent.rect_size / 2


# Event handlers
# Focar node pai quando o mouse focá-lo.
func _on_parent_mouse_entered() -> void:
	if mouse_focus_grab and _parent.focus_mode != Control.FOCUS_NONE:
		_parent.grab_focus()


# Desfocar node pai quando o mouse desfocá-lo.
func _on_parent_mouse_exited() -> void:
	if mouse_focus_release and _parent.focus_mode != Control.FOCUS_NONE:
		_parent.release_focus()


# Iniciar animações dos botões no quadro seguinte.
func _on_idle_frame() -> void:
	_animate_brightness()
	_animate_rotation()
	_animate_scale()


# Alterar brilho quando o node pai for pressionado.
func _on_parent_button_down() -> void:
	_set_brightness(pressed_brightness)


# Alterar o brilho e tocar som quando o node pai for solto.
func _on_parent_button_up(_arg = null) -> void:
	_set_brightness(normal_brightness)
	_play_click_sound()


# Deleta o player de áudio ao terminar o som de click.
func _on_audio_player_finished(audio_player: AudioStreamPlayer) -> void:
	audio_player.queue_free()


# Executar loop de animação sempre que o loop anterior terminar.
func _on_tween_finished(method: String) -> void:
	call(method)

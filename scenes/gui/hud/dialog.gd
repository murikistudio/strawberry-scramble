extends VBoxContainer


# Constants
const SPEED_SHOW := 0.5
const SPEED_HIDE := 1.0
const CHARACTER_VISIBLE_TIME := 0.1
const CHARACTER_MIN_LEN := 30
const DIALOGS := {
	"mom": {
		"start": [
			"dlg_mom_start_1",
			"dlg_mom_start_2",
			"dlg_mom_start_3",
			"dlg_mom_start_4",
			"dlg_mom_start_5",
		],
		"incomplete": [
			"dlg_mom_incomplete_1",
			"dlg_mom_incomplete_2",
			"dlg_mom_incomplete_3",
			"dlg_mom_incomplete_4",
			"dlg_mom_incomplete_5",
		],
	},
	"man": {
		"death": [
			"dlg_man_death_1",
			"dlg_man_death_2",
			"dlg_man_death_3",
			"dlg_man_death_4",
			"dlg_man_death_5",
		],
		"complete": [
			"dlg_man_complete_1",
			"dlg_man_complete_2",
			"dlg_man_complete_3",
			"dlg_man_complete_4",
			"dlg_man_complete_5",
		],
	},
}


# Variables
export(Texture) var texture_man: Texture
export(Texture) var texture_mom: Texture
export(Texture) var texture_player: Texture

var _current_dialog := ""

onready var _label_name: Label = find_node("LabelName")
onready var _label_text: Label = find_node("LabelText")
onready var _texture_rect_portrait: TextureRect = find_node("TextureRectPortrait")
onready var _tween: Tween = find_node("Tween")


# Built-in overrides
func _ready() -> void:
	modulate.a = 0.0
	GameEvents.connect("level_dialog", self, "_show_dialog")


# Private methods
func _show_dialog(character: String, dialog: String) -> void:
	var dialogs: Array = DIALOGS.get(character, {}).get(dialog, [])

	var current_dialog := character + "_" + dialog

	if current_dialog == _current_dialog:
		return

	_current_dialog = current_dialog

	var sfx_path := DatabaseAudio.SFX_BASE + _current_dialog + ".wav"

	if not ResourceLoader.exists(sfx_path):
		sfx_path = DatabaseAudio.SFX_BASE + character + ".wav"

	GameAudio.play_sfx(sfx_path)

	var texture: Texture = get("texture_" + character)
	_texture_rect_portrait.texture = texture

	if dialogs.size():
		randomize()
		dialog = dialogs[randi() % dialogs.size()]
	else:
		dialog = "_".join(["dlg", character, dialog])

	_label_name.text = tr(character) + ":"
	_label_text.text = tr(dialog)

	_tween.remove_all()

	# Fade in
	_tween.interpolate_property(self, "modulate:a", 0.0, 1.0, SPEED_SHOW)
	_tween.interpolate_property(_label_text, "percent_visible", 0.0, 1.0, SPEED_SHOW * 2.0)

	# Fade out
	var visible_time := max(_label_text.text.length(), CHARACTER_MIN_LEN) * CHARACTER_VISIBLE_TIME

	_tween.interpolate_property(
		self, "modulate:a", 1.0, 0.0, SPEED_SHOW,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, visible_time
	)

	_tween.start()


func _on_Tween_tween_all_completed() -> void:
	_current_dialog = ""

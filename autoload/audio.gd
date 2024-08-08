extends AudioStreamPlayer
# Singleton that manages the playback of music and sound effects in the game.


# Constants
const FADE_SPEED := 0.25
const VOLUME_MIN := -80.0
const VOLUME_MAX := 0.0
const DEFAULT_BUS_SFX := "SFX"
const DEFAULT_BUS_BGM := "BGM"


# Variables
var _current_music := ""
var _hashes := {}

onready var _tween: Tween = Tween.new()


# Built-in overrides
func _ready() -> void:
	bus = DEFAULT_BUS_BGM
	pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(_tween)


# Public methods
# Plays the music from the specified file path.
func play_bgm(file) -> void:
	if _tween.is_active():
		return

	if typeof(file) == TYPE_STRING and file == _current_music \
	or typeof(file) == TYPE_OBJECT and file == stream:
		return

	var _stream := _get_stream(file)

	if not _stream:
		return

	if stream:
		_tween.interpolate_property(self, "volume_db", VOLUME_MAX, VOLUME_MIN, FADE_SPEED)
		_tween.start()
		yield(_tween, "tween_all_completed")
		stream = null

	stream = _stream
	_current_music = _stream.resource_path
	play(0.0)
	_tween.interpolate_property(self, "volume_db", VOLUME_MIN, VOLUME_MAX, FADE_SPEED)
	_tween.start()


# Plays a sound effect from an AudioStream or file path.
func play_sfx(file, vol := 0.0, pitch := 1.0) -> void:
	var _stream := _get_stream(file)

	if not _stream:
		return

	var audio := AudioStreamPlayer.new()
	audio.stream = _stream
	audio.pitch_scale = pitch
	audio.bus = DEFAULT_BUS_SFX
	audio.volume_db = vol
	audio.play()
	audio.connect("finished", self, "_on_audio_finished", [audio])
	add_child(audio)


# Plays a 3D sound effect on the position of the specified spatial node.
func play_sfx_3d(node: Spatial, file, unit_size := 1.0, pitch := 1.0) -> void:
	var _stream := _get_stream(file)

	if not _stream:
		return

	var audio := AudioStreamPlayer3D.new()
	audio.stream = _stream
	audio.pitch_scale = pitch
	audio.bus = DEFAULT_BUS_SFX
	audio.unit_size = unit_size
	audio.play()
	audio.connect("finished", self, "_on_audio_finished", [audio])
	node.add_child(audio)


# Private methods
# Returns the audio stream from a path, or null if invalid.
func _get_stream(file) -> AudioStream:
	if not file:
		return null

	if typeof(file) == TYPE_STRING and ResourceLoader.exists(file):
		return load(file) as AudioStream

	if typeof(file) == TYPE_OBJECT and file.is_class("AudioStream"):
		return file

	return null


# Event handlers
# Delete the audio player after playback.
func _on_audio_finished(audio: Node) -> void:
	audio.queue_free()

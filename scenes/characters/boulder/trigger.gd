extends Area


# Variables
export(NodePath) var target_spawner: NodePath
export(String, "spawn", "enable", "disable") var trigger_mode := "spawn"
export(float, -1.0, 30.0, 0.01) var trigger_interval := -1.0
var _target_spawner: Spatial
var _can_trigger := true
onready var _timer: Timer = find_node("Timer")


# Built-in overrides
func _ready() -> void:
	if not target_spawner:
		queue_free()
		return

	_target_spawner = get_node(target_spawner)


# Event handlers
func _on_BoulderTrigger_body_entered(body: Spatial) -> void:
	if not _can_trigger or not _target_spawner or not "player" in body.name.to_lower():
		return

	GameEvents.emit_signal("level_boulder_triggered", _target_spawner, trigger_mode)
	_can_trigger = false

	if trigger_interval > 0.0:
		_timer.wait_time = trigger_interval
		_timer.start()


func _on_Timer_timeout() -> void:
	_can_trigger = true

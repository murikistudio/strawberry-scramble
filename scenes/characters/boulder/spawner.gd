extends Spatial


# Variables
export var enabled := true
export(float, 0.0, 10.0, 0.01) var rotation_speed := 1.0
export var direction := Vector3.ZERO
export(PackedScene) var scene_boulder: PackedScene


# Built-in overrides
func _ready() -> void:
	GameEvents.connect("level_boulder_triggered", self, "_on_level_boulder_triggered")


# Event handlers
func _on_level_boulder_triggered(spawner: Spatial, mode: String) -> void:
	if spawner != self:
		return

	if mode == "spawn" and enabled:
		var boulder: Spatial = scene_boulder.instance()
		boulder.rotation_speed = rotation_speed
		boulder.direction = direction
		add_child(boulder)
		boulder.global_transform = global_transform

	elif mode == "enable":
		enabled = true

	elif mode == "disable":
		enabled = false

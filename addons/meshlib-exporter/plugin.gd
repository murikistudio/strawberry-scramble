tool
extends EditorPlugin


# Variables
var _can_save := true
var _extension := ".tres"


# Built-in overrides
func apply_changes() -> void:
	var editor := get_editor_interface()
	var scene := editor.get_edited_scene_root()

	if not _can_save or not scene or not scene.name.capitalize().begins_with("Lib "):
		return

	var resource_name := scene.name.capitalize().to_lower().replace(" ", "_")
	var scene_name := ""
	var scene_path := ""

	for fn in editor.get_open_scenes():
		var filename := fn as String
		filename = filename.get_file().replace("." + filename.get_extension(), "")
		filename = filename.capitalize().to_lower().replace(" ", "_")

		if filename == resource_name:
			scene_name = filename
			scene_path = fn.replace(fn.get_file(), "")
			break

	if resource_name != scene_name:
		return

	var directory := Directory.new()
	var mesh_lib := MeshLibrary.new()

	for i in scene.get_child_count():
		var child: Node = scene.get_child(i)

		mesh_lib.create_item(i)
		mesh_lib.set_item_name(i, child.name)

		if child.filename:
			var preview_path := child.filename.replace("." + child.filename.get_extension(), "_preview.png")

			if directory.file_exists(preview_path):
				mesh_lib.set_item_preview(i, load(preview_path))

		_iterate_child(mesh_lib, i, child)

	var resource_path := scene_path + resource_name + _extension

	if directory.file_exists(resource_path):
		directory.remove(resource_path)

	_can_save = false
	ResourceSaver.save(resource_path, mesh_lib)
	prints("Saved", mesh_lib.get_item_list().size(), "items on", resource_path)
	yield(get_tree().create_timer(1.0), "timeout")
	_can_save = true


# Private methods
func _iterate_child(mesh_lib: MeshLibrary, i: int, node: Node):
	if node != null:
		if node is MeshInstance:
			mesh_lib.set_item_mesh(i, node.mesh)

		elif node is CollisionShape:
			mesh_lib.set_item_shapes(i, [node.shape])

		for child in node.get_children():
			_iterate_child(mesh_lib, i, child)

@tool
class_name Btn extends Control

signal clicked

var disabled := false

@export var text: String = ""
@export_tool_button("update") var upd = _update
@export var hbox: HBoxContainer

func _destroy_text() -> void {
	if not Engine.is_editor_hint(): return
	assert(hbox, "no hbox slotted in!")
	for child in hbox.get_children() {
		child.queue_free()
	}
}

func _update() -> void {
	if not Engine.is_editor_hint(): return
	assert(hbox, "no hbox slotted in!")
	_destroy_text()
	for i_char in text {
		var g := Glyph.from_char(i_char)
		hbox.add_child(g)
		g.owner = get_tree().edited_scene_root
	}
}

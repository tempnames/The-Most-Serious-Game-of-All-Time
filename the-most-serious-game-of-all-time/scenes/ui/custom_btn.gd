class_name CustomTxt extends CascadeV3

signal pressed

@export var disabled := false

func _input(event: InputEvent) -> void {
	if disabled: return
	if event is InputEventMouseButton {
		var m_event := event as InputEventMouseButton
		if get_global_rect().has_point(m_event.global_position) and m_event.button_index == MOUSE_BUTTON_LEFT and m_event.pressed {
			pressed.emit()
		}
	}
}

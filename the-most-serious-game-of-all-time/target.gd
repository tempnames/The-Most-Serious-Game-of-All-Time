extends Area2D

@export var manager: Node2D

func _mouse_enter() -> void {
	manager.register_target(self)
}

func _mouse_exit() -> void {
	manager.unregister_target(self)
}

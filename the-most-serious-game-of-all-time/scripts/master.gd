class_name Master
extends Control

enum Scenes {
	COMBAT
}

var scene_node: Node

func _enter_tree() -> void {
	scene_node = Node.new()
	add_child(scene_node)
	
	GamestateManager.switch_to.connect(_perform_switch)
	print(GamestateManager.switch_to.is_connected(_perform_switch))
}

func _perform_switch(scene: Scenes) -> void {
	for old_scene in scene_node.get_children() {
		old_scene.queue_free()
	}
	var new_scene: PackedScene
	match scene:
		Scenes.COMBAT:
			new_scene = preload("uid://cvxp3frvyn2dc")
	if new_scene and new_scene.can_instantiate() {
		scene_node.add_child(new_scene.instantiate())
	}
}

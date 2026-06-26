class_name Master
extends Control

enum Scenes {
	COMBAT,
	EVENT,
	GAMEOVER
}

var scene_node: Node

func _enter_tree() -> void {
	scene_node = Node.new()
	add_child(scene_node)
	
	GamestateManager.switch_to.connect(_perform_switch)
}

func _perform_switch(scene: Scenes) -> void {
	for old_scene in scene_node.get_children() {
		old_scene.queue_free()
	}
	var new_scene: PackedScene
	match scene:
		Scenes.COMBAT:
			new_scene = preload("uid://cvxp3frvyn2dc")
		Scenes.EVENT:
			new_scene = preload("uid://bu7obgx0nva42")
		_: 
			assert(false, "unimplemented!") #explode on invalid invariants
	
	if new_scene and new_scene.can_instantiate() {
		scene_node.add_child(new_scene.instantiate())
	}
}

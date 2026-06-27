class_name Master
extends Control

enum Scenes {
	MENU,
	TUTORIAL,
	COMBAT,
	EVENT,
	GAMEOVER,
	CREDITS
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
		Scenes.MENU:
			new_scene = preload("uid://dk76twclqhkm5")
		Scenes.TUTORIAL:
			new_scene = preload("uid://o23s7nf861t")
		Scenes.COMBAT:
			new_scene = preload("uid://cvxp3frvyn2dc")
		Scenes.EVENT:
			new_scene = preload("uid://bu7obgx0nva42")
		Scenes.CREDITS:
			new_scene = preload("uid://cudck3air31vg")
		Scenes.GAMEOVER:
			new_scene = preload("uid://dvin0tx17ty43")
	
	if new_scene and new_scene.can_instantiate() {
		scene_node.add_child(new_scene.instantiate())
	}
}

class_name Master
extends Control

@export var music: AudioStreamPlayer2D

enum Scenes {
	MENU,
	TUTORIAL,
	COMBAT,
	EVENT,
	GAMEOVER,
	CREDITS
}

var scene_node: Node
var prev_scene: Scenes

func _enter_tree() -> void {
	scene_node = Node.new()
	add_child(scene_node)
	
	GamestateManager.switch_to.connect(_perform_switch)
}

func _ready() -> void {
	start_bg()
	prev_scene = Scenes.MENU
}

func reset_music_signals() -> void {
	if music.finished.is_connected(loop_finished):
		music.finished.disconnect(loop_finished)
	if music.finished.is_connected(intro_finished):
		music.finished.disconnect(intro_finished)
}

func start_bg() -> void {
	reset_music_signals()
	music.stream = preload("uid://d3hwfqytlro7g")
	music.play()
	music.finished.connect(loop_finished)
}

func start_combat() -> void {
	reset_music_signals()
	music.stream = preload("uid://b2dxtgyylhw7d")
	music.play()
	music.finished.connect(intro_finished)
}

func intro_finished() -> void {
	reset_music_signals()
	music.stream = preload("uid://cf22u8foqupff")
	music.play()
	music.finished.connect(loop_finished)
}

func loop_finished() -> void {
	music.play()
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
	
	if scene == Scenes.COMBAT {
		start_combat()
	} elif prev_scene == Scenes.COMBAT {
		start_bg()
	}
	
	if new_scene and new_scene.can_instantiate() {
		scene_node.add_child(new_scene.instantiate())
	}
	
	prev_scene = scene
}

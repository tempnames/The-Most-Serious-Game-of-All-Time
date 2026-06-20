class_name GameState
extends Node

@export var current_enemy: Enemy
@export var inventory: Array[SpinnerData]
@export_category("Scenes")
@export var combat: PackedScene = preload("uid://cvxp3frvyn2dc")

signal switch_to(scene: PackedScene)

func new_game() {
	inventory = [SpinnerData.new()]
	current_enemy = null
}

func encounter_enemy(enemy: Enemy) {
	current_enemy = enemy
	switch_to.emit(combat)
}

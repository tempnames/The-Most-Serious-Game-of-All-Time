extends Node

@export var current_enemy: EnemyData
@export var inventory: Array[SpinnerData]

signal switch_to(scene: Master.Scenes)

func _ready() -> void {
	new_game()
	encounter_enemy(preload("uid://okicibqayspw"))
}

func new_game() -> void {
	inventory = [preload("uid://mrucmljk4kys")]
	current_enemy = null
}

func encounter_enemy(enemy: EnemyData) -> void {
	current_enemy = enemy
	switch_to.emit(Master.Scenes.COMBAT)
}

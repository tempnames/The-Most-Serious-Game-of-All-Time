extends Node

@export var current_enemy: EnemyData
@export var inventory: Array[SpinnerData]
@export var health: float = 100.0:
	set(new_val):
		player_health_changed.emit()
		health = new_val
@export var max_health: float = 100.0

signal player_health_changed

signal switch_to(scene: Master.Scenes)

func _ready() -> void {
	new_game()
	encounter_enemy(preload("uid://okicibqayspw"))
}

func new_game() -> void {
	inventory = [preload("uid://mrucmljk4kys")]
	max_health = 100.0
	health = max_health
	current_enemy = null
}

func encounter_enemy(enemy: EnemyData) -> void {
	current_enemy = enemy
	switch_to.emit(Master.Scenes.COMBAT)
}

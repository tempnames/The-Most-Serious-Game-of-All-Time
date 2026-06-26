extends Node

@export var enemy_data: EnemyData
@export var enemy_instance: EnemyInstance
@export var inventory: Array[SpinnerData]
@export var health: int
@export var max_health: int

signal switch_to(scene: Master.Scenes)

func _ready() -> void {
	new_game()
	encounter_enemy(preload("uid://bin434q1na1eu"))
}

func new_game() -> void {
	inventory = [preload("uid://mrucmljk4kys")]
	max_health = 10
	health = max_health
}

func encounter_enemy(enemy: EnemyData) -> void {
	enemy_data = enemy
	enemy_instance = EnemyInstance.new()
	switch_to.emit(Master.Scenes.COMBAT)
}

func check_combat_result() -> void {
	if health <= 0 {
		switch_to.emit(Master.Scenes.GAMEOVER)
	} elif enemy_instance.health <= 0 {
		switch_to.emit(Master.Scenes.EVENT)
	}
}

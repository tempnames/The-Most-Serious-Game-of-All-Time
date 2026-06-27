extends Node

@export var enemy_data: EnemyData
@export var enemy_instance: EnemyInstance
@export var inventory: Array[SpinnerData]
@export var health: int
@export var max_health: int
@export var atk_mult: float
@export var blk_mult: float
@export var flags: Dictionary[Flag, bool]
@export var difficulty := 0.0
@export var enemies: Array[EnemyData]
@export var previous_event: EventManager.Event

enum Flag {
	SONGPHEUS,
	EURYCARDICE,
	TOGETHER_AGAIN
}

signal switch_to(scene: Master.Scenes)

func _ready() -> void {
	new_game()
}

func new_game() -> void {
	inventory = [preload("uid://mrucmljk4kys")]
	max_health = 50
	health = max_health
	atk_mult = 1.0
	blk_mult = 1.0
	difficulty = 0.0
	enemies = [
		preload("uid://pqy80v8ok7hn"),
		preload("uid://bqi4k4dgtchsm"),
		preload("uid://bedxen1jdiai5"),
		preload("uid://bwm61ht8gi117"),
		preload("uid://cj00jjw82ph3s")
	]
	encounter_enemy()
}

func encounter_enemy() -> void {
	var enemy_idx = clampi(clampi(roundi(difficulty), 0, enemies.size()-1) + randi_range(-1, 1), 0, enemies.size()-1)
	enemy_data = enemies[enemy_idx]
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

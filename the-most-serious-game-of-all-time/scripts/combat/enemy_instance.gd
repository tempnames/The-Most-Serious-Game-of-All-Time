class_name EnemyInstance
extends Resource

var health: int
var block: int

func start_battle(data: EnemyData) -> void {
	health = data.max_health
	block = 0
}

func next_turn() -> void {
	block = 0
}

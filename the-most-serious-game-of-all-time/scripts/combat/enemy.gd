class_name Enemy
extends Sprite2D

@export var enemy_lock: TargetLock

func _enter_tree() -> void {
	enemy_lock = TargetLock.new()
	var enemy_lock_shape := CircleShape2D.new()
	enemy_lock_shape.radius = 64
	enemy_lock.collision_shape = enemy_lock_shape
	enemy_lock.lock_type = Target.Type.ENEMY
	add_child(enemy_lock)
}

func _ready() -> void {
	texture = GamestateManager.current_enemy.sprite
}

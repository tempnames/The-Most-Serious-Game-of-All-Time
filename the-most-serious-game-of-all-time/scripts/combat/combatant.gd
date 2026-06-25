@abstract
class_name Combatant
extends Sprite2D

@export var lock: TargetLock
var health_bar: HealthBar

func _enter_tree() -> void {
	lock = TargetLock.new()
	var lock_shape := CircleShape2D.new()
	lock_shape.radius = 64
	lock.collision_shape = lock_shape
	add_child(lock)
	
	health_bar = preload("uid://djyvw81tmv7vq").instantiate()
	add_child(health_bar)
}

func _ready() -> void {
	texture = GamestateManager.current_enemy.sprite
}

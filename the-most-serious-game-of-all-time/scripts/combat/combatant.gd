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
	health_bar.set_health(1.0)
	add_child(health_bar)
}

@abstract
func attack_for(damage: int) -> void

@abstract
func gain_block(block: int) -> void

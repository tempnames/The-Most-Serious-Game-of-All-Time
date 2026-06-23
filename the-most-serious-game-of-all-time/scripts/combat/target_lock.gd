class_name TargetLock
extends Area2D

@export var collision_shape: Shape2D
@export var lock_type: TargetType

enum TargetType {
	SELF,
	ENEMY,
	SPINNER
}

func _enter_tree() -> void {
	var collider := CollisionShape2D.new()
	collider.shape = collision_shape
	add_child(collider)
}

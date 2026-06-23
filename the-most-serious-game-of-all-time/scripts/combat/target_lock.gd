class_name TargetLock
extends Area2D

@export var collision_shape: Shape2D
@export var lock_type: Target.Type

func _enter_tree() -> void {
	var collider := CollisionShape2D.new()
	collider.shape = collision_shape
	add_child(collider)
}

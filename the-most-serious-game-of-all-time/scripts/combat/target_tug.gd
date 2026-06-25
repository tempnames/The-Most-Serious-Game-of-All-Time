class_name TargetTug
extends Area2D

@export var valid_targets: Target.Type = Target.Type.NONE
var collider: CollisionShape2D
var collider_shape: RectangleShape2D
const sprite_tex: Texture2D = preload("uid://dd51qno3rnrh1")

signal start_arrow()
signal stop_arrow()
signal detach_arrow()
signal target_registered(potential_combatant: Option[Combatant], potential_spinner: Option[Variant])

func _enter_tree() -> void {
	var sprite := Sprite2D.new()
	sprite.centered = false
	sprite.texture = sprite_tex
	sprite.scale.y = 1.2
	sprite.position.y -= sprite.scale.y * sprite_tex.get_size().y/2
	add_child(sprite)
	
	collider = CollisionShape2D.new()
	collider_shape = RectangleShape2D.new()
	collider_shape.size = Vector2(80, 60)
	collider.shape = collider_shape
	collider.position.x = 20
	add_child(collider)
}

func _input(event: InputEvent) -> void {
	if event is InputEventMouseButton {
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT {
			if mouse_event.pressed {
				var collision_area := collider_shape.get_rect()
				collision_area.position += collider.position
				if collision_area.has_point(to_local(mouse_event.global_position)) {
					start_arrow.emit()
				}
			} else {
				stop_arrow.emit()
			}
		}
	}
}

func try_attach(t: TargetLock) -> bool {
	return (t.lock_type & valid_targets) > Target.Type.NONE
}

func register_target(t: TargetLock) -> void {
	if t.lock_type == Target.Type.SPINNER {
		target_registered.emit(Option.none(), Option.some(t.parent_ref))
	} else {
		target_registered.emit(Option.some(t.parent_ref), Option.none())
	}
}

class_name Arrow
extends NinePatchRect

# set:
# texture = as necessary
# region rect = size of texture
# patch margin.right = width of arrowhead
# patch margin.other = as necessary
# size.y = height of arrow

@export var target_pos: Vector2:
	get():
		return target_pos
	set(new_val):
		target_pos = new_val
		rotation = global_position.direction_to(target_pos).angle()
		size.x = global_position.distance_to(target_pos)

func _ready() -> void {
	offset_transform_enabled = true
	offset_transform_position_ratio = Vector2(0, -0.5)
}

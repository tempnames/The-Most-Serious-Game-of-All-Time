class_name WobblyPolygon extends Polygon2D

@export var wobbling := true
@export var wobble_radius := 6.0
@export var wobble_speed := 1.0
@export var start_randomly := false

var _base_points: PackedVector2Array
var _time := 0.0

func _ready() -> void:
	_base_points = polygon.duplicate()
	if start_randomly: _time = randf_range(0.0, 11.0)

func _process(delta: float) -> void:
	if not wobbling: return
	
	_time += delta * wobble_speed
	
	var new_points := PackedVector2Array()
	new_points.resize(_base_points.size())
	
	for i in _base_points.size():
		var base := _base_points[i]
		
		var phase_x := float(i) * 1.37
		var phase_y := float(i) * 2.11
		
		var offset_vec := Vector2(
			sin(_time + phase_x),
			cos(_time + phase_y)
		) * wobble_radius
		
		new_points[i] = base + offset_vec
	
	polygon = new_points

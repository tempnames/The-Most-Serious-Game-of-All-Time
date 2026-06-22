extends Control

@export var player_spinners: SpinnerCollection
@export var enemy_spinners: SpinnerCollection
var origin: Option[TargetTug] = Option.none()
@export var arrows: Dictionary[TargetTug, Arrow]
@export var arrows_layer: CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void {
	player_spinners.spinners_updated.connect(_on_spinner_refresh)
	enemy_spinners.spinners_updated.connect(_on_spinner_refresh)
	_on_spinner_refresh()
}

func _process(_delta: float) -> void {
	if origin.is_some() {
		var c_origin := origin.unwrap_unchecked()
		var arrow := arrows.get(c_origin) as Arrow
		if arrow {
			arrow.target_pos = get_global_mouse_position()
		}
	}
}

func _on_spinner_refresh() -> void {
	for spinner in player_spinners.spinner_nodes + enemy_spinners.spinner_nodes {
		for tug in spinner.target_tugs {
			if tug.stop_arrow.is_connected(_stop_arrow) {
				continue
			}
			tug.start_arrow.connect(_start_arrow.bind(tug))
			tug.stop_arrow.connect(_stop_arrow)
		}
	}
}

func _start_arrow(o: TargetTug) -> void {
	origin = Option.some(o)
	if not arrows.has(o) {
		var arrow := Arrow.new()
		arrow.texture = preload("res://icon.svg")
		arrow.region_rect = Rect2(Vector2.ZERO, arrow.texture.get_size())
		arrow.size.y = 16
		arrow.global_position = o.global_position
		arrows_layer.add_child(arrow)
		arrows.set(o, arrow)
	}
}

func _stop_arrow() -> void {
	if origin.is_some() {
		var c_origin := origin.unwrap_unchecked()
		var arrow_node := arrows.get(c_origin) as Arrow
		if arrow_node {
			arrow_node.queue_free()
			arrows.erase(c_origin)
		}
		origin = Option.none()
	}
}

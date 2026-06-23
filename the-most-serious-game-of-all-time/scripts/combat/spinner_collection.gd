class_name SpinnerCollection
extends Control

@export var enemy: bool = false
@export var padding: float = 10.0
@export var max_wheel_size: float = 100
@export var spinners: Array[SpinnerData]:
	set(data):
		spinners = data
		refresh_spinners()
@export var overlays: Array[Texture2D]
@export var spinner_nodes: Array[Spinner]

var old_wheel_height := 0

signal spinners_updated

func _ready() -> void {
	refresh_spinners()
}

func _process(delta: float) -> void {
	var spinner_count := spinners.size()
	var padding_count := maxi(0, spinner_count-1)
	var wheel_height := minf(max_wheel_size*2, (size.y - padding*padding_count)/(spinner_count as float))
	if old_wheel_height != wheel_height {
		var total_height := wheel_height*spinner_count + padding*padding_count
		var pos := (size.y-total_height)/2 + wheel_height/2
		var pos_inc := wheel_height+padding
		for spinner in spinner_nodes {
			spinner.size = wheel_height/2
			spinner.position.y = pos
			spinner.resize_wheel()
			pos += pos_inc
		}
	}
}

func refresh_spinners() -> void {
	var spinner_count := spinners.size()
	var old_spinner_count := spinner_nodes.size()
	var queue_emit := false
	if spinner_count > old_spinner_count {
		for i in range(old_spinner_count, spinner_count) {
			var spinner := Spinner.new()
			spinner_nodes.append(spinner)
			spinner.spun.connect(_spinners_spun)
			add_child.call_deferred(spinner)
		}
		queue_emit = true
	} elif spinner_count < old_spinner_count {
		for i in range(old_spinner_count-1, spinner_count-1, -1) {
			spinner_nodes[i].queue_free()
			spinner_nodes.pop_back()
		}
		queue_emit = true
	}
	for i in range(spinner_count) {
		if spinner_nodes[i].data != spinners[i] {
			spinner_nodes[i].enemy = enemy
			spinner_nodes[i].data = spinners[i]
			queue_emit = true
		}
	}
	if queue_emit {
		spinners_updated.emit()
	}
}

func _spinners_spun() -> void {
	spinners_updated.emit()
}

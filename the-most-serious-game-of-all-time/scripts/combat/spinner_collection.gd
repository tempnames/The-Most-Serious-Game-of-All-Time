extends Node2D

@export var height: float = 630
@export var padding: float = 10.0
@export var max_wheel_size: float = 100
@export var spinners: Array[SpinnerData]:
	set(data):
		spinners = data
		refresh_spinners()
@export var spinner_nodes: Array[Spinner]

func _ready() -> void {
	refresh_spinners()
}

func refresh_spinners() -> void {
	var spinner_count := spinners.size()
	var old_spinner_count := spinner_nodes.size()
	if spinner_count > old_spinner_count {
		for i in range(old_spinner_count, spinner_count) {
			var spinner := Spinner.new()
			spinner.data = spinners[i]
			spinner_nodes.append(spinner)
			add_child(spinner)
		}
	} elif spinner_count < old_spinner_count {
		for i in range(old_spinner_count-1, spinner_count-1, -1) {
			spinner_nodes[i].queue_free()
			spinner_nodes.pop_back()
		}
	}
	
	var padding_count := maxi(0, spinner_count-1)
	var wheel_height := minf(max_wheel_size*2, (height - padding*padding_count)/(spinner_count as float))
	var real_height := wheel_height*spinner_count + padding*padding_count
	var pos := -real_height/2 + wheel_height/2
	var pos_inc := wheel_height+padding
	for spinner in spinner_nodes {
		spinner.refresh_wheel()
		spinner.size = wheel_height/2
		spinner.position.y = pos
		pos += pos_inc
	}
}

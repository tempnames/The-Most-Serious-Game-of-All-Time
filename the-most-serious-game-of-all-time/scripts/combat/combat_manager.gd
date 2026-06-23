extends Control

@export var player_spinners: SpinnerCollection
@export var enemy_spinners: SpinnerCollection
@export var target_btn: Button
@export var spin_btn: Button
var origin: Option[TargetTug] = Option.none()
var arrows: Dictionary[TargetTug, Arrow]
@export var arrows_layer: CanvasLayer
var target_locks: Array[TargetLock]
var targets: Array[TargetLock]

enum State {
	PRESPIN,
	TARGET,
	COMBAT
}
var state: State = State.PRESPIN

var spinners_spinning := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void {
	target_btn.disabled = true
	target_btn.visible = false
	target_btn.pressed.connect(_on_target_btn_press)
	spin_btn.pressed.connect(_on_spin_btn_press)
	player_spinners.spinners_updated.connect(_on_spinner_refresh)
	enemy_spinners.spinners_updated.connect(_on_spinner_refresh)
	_on_spinner_refresh()
}

func _process(_delta: float) -> void {
	if state == State.TARGET {
		if origin.is_some() {
			var c_origin := origin.unwrap_unchecked()
			var arrow := arrows.get(c_origin) as Arrow
			if arrow {
				if targets.size() == 0 {
					arrow.target_pos = get_global_mouse_position()
				} else {
					arrow.target_pos = targets[targets.size()-1].global_position
				}
			}
		}
	}
}

func _on_spinner_refresh() -> void {
	for spinner in player_spinners.spinner_nodes {
		for tug in spinner.target_tugs {
			if tug.stop_arrow.is_connected(_stop_arrow) {
				continue
			}
			tug.start_arrow.connect(_start_arrow.bind(tug))
			tug.stop_arrow.connect(_stop_arrow)
		}
	}
	for spinner in enemy_spinners.spinner_nodes {
		spinner.spinner_lock.and_then(func(lock: TargetLock) {
			target_locks.push_back(lock)
			if lock.mouse_exited.is_connected(_exit_lock.bind(lock)) {
				return
			}
			lock.mouse_entered.connect(_enter_lock.bind(lock))
			lock.mouse_exited.connect(_exit_lock.bind(lock))
		})
	}
}

func _start_arrow(o: TargetTug) -> void {
	if not state == State.TARGET { return }
	origin = Option.some(o)
	o.visible = false
	if not arrows.has(o) {
		var arrow := Arrow.new()
		arrow.texture = preload("uid://dd51qno3rnrh1")
		arrow.patch_margin_left = 4
		arrow.patch_margin_right = 16
		arrow.size.y = 32
		arrow.global_position = o.global_position
		arrows_layer.add_child(arrow)
		arrows.set(o, arrow)
	}
}

func _stop_arrow() -> void {
	if not state == State.TARGET { return }
	if origin.is_some() {
		var c_origin := origin.unwrap_unchecked()
		if targets.size() == 0 or not c_origin.try_attach(targets[targets.size()-1]) {
			var arrow_node := arrows.get(c_origin) as Arrow
			if arrow_node {
				arrow_node.queue_free()
				arrows.erase(c_origin)
			}
			c_origin.visible = true
		} else {
			c_origin.register_target(targets[targets.size()-1])
		}
		origin = Option.none()
	}
}

func _enter_lock(lock: TargetLock) -> void {
	_exit_lock(lock)
	targets.push_back(lock)
}

func _exit_lock(lock: TargetLock) -> void {
	targets.erase(lock)
}

func _on_target_btn_press() -> void {
	target_btn.disabled = true
	target_btn.visible = false
	spin_btn.disabled = false
	spin_btn.visible = true
}

func _on_spin_btn_press() -> void {
	spin_btn.disabled = true
	spin_btn.visible = false
	for spinner in player_spinners.spinner_nodes + enemy_spinners.spinner_nodes {
		spinner.spin()
		spinner.spun.connect(_despin.bind(spinner))
		spinners_spinning += 1
	}
}

func _despin(spinner: Spinner) -> void {
	spinner.spun.disconnect(_despin.bind(spinner))
	spinners_spinning -= 1
	if spinners_spinning == 0 {
		state = State.TARGET
		target_btn.disabled = false
		target_btn.visible = true
	}
}

extends Control

@export var player_spinners: SpinnerCollection
@export var enemy_spinners: SpinnerCollection
@export var target_btn: CustomTxt
@export var spin_btn: Button
@export var enemy: Enemy
@export var player: Player
var origin: Option[TargetTug] = Option.none()
var arrows: Dictionary[TargetTug, Arrow]
@export var arrows_layer: CanvasLayer
var target_locks: Array[TargetLock]
var targets: Array[TargetLock]

enum State {
	PRESPIN,
	TARGET
}
var state: State = State.PRESPIN

var spinners_spinning := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void {
	#target_btn.visible = false
	#target_btn.disabled = true
	#target_btn.clicked.connect(_on_target_btn_press)
	# temp line
	spin_btn.pressed.connect(_on_target_btn_press)
	
	spin_btn.pressed.connect(_on_spin_btn_press)
	
	player_spinners.spinners = GamestateManager.inventory
	player_spinners.spinners_updated.connect(_on_spinner_refresh)
	enemy_spinners.spinners = GamestateManager.enemy_data.spinners
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

func _per_tug(action: Callable) -> void {
	for spinner in player_spinners.spinner_nodes {
		for tug in spinner.target_tugs {
			action.call(tug)
		}
	}
}

func _on_spinner_refresh() -> void {
	_per_tug(func(t: TargetTug) {
		if t.stop_arrow.is_connected(_stop_arrow) {
			return
		}
		t.start_arrow.connect(_start_arrow.bind(t))
		t.detach_arrow.connect(_detach_arrow.bind(t))
		t.stop_arrow.connect(_stop_arrow)
	})
	for spinner in enemy_spinners.spinner_nodes {
		spinner.spinner_lock.and_then(_connect_lock)
	}
	_connect_lock(enemy.lock)
	_connect_lock(player.lock)
}

func _connect_lock(lock: TargetLock) -> void {
	target_locks.push_back(lock)
	if lock.mouse_exited.is_connected(_exit_lock.bind(lock)) {
		return
	}
	lock.mouse_entered.connect(_enter_lock.bind(lock))
	lock.mouse_exited.connect(_exit_lock.bind(lock))
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
			_detach_arrow(c_origin)
		} else {
			c_origin.register_target(targets[targets.size()-1])
		}
		origin = Option.none()
	}
}

func _detach_arrow(o: TargetTug) {
	var arrow_node := arrows.get(o) as Arrow
	if arrow_node {
		arrow_node.queue_free()
		arrows.erase(o)
	}
	o.visible = true
}

func _enter_lock(lock: TargetLock) -> void {
	if origin.is_some() {
		var c_origin := origin.unwrap_unchecked()
		if c_origin.try_attach(lock) {
			_exit_lock(lock)
			targets.push_back(lock)
		}
	}
}

func _exit_lock(lock: TargetLock) -> void {
	targets.erase(lock)
}

func _on_target_btn_press() -> void {
	if state != State.TARGET: return
	#target_btn.disabled = true
	#target_btn.visible = false
	_per_tug(func(t: TargetTug) {
		t.visible = false
	})
	
	enemy.perform_turn(enemy_spinners.spinner_nodes, player)
	
	_do_combat()
}

func _do_combat() -> void {
	var queue := player_spinners.spinner_nodes + enemy_spinners.spinner_nodes
	queue.sort_custom(func(a: Spinner, b: Spinner) -> bool {
		if a.speed > b.speed {
			return true
		} elif a.speed == b.speed {
			# Give the player a slight advantage
			# in otherwise even matches
			return not a.enemy
		} else {
			return false
		}
	})
	for spinner in queue {
		if spinner.chosen_card_idx.is_none() { continue }
		var c_card_idx = spinner.chosen_card_idx.unwrap_unchecked()
		
		var card_slice := (spinner.wheel.get_child(c_card_idx) as Polygon2D)
		var tween := create_tween().set_trans(Tween.TRANS_EXPO)
		tween.tween_property(card_slice, "scale", card_slice.scale * 1.1, 0.3)
		spinner.roll_effect()
		await tween.finished
		
		var node: Combatant
		var target_pos: Vector2
		var origin_pos: Vector2
		if spinner.enemy {
			node = enemy
			origin_pos = enemy.global_position
		} else {
			node = player
			origin_pos = player.global_position
		}
		if spinner.data.cards[c_card_idx].effects.any(func(e: Effect) -> bool{
			return e.effect_type == Effect.Type.ATTACK
		}) {
			if spinner.enemy {
				target_pos = player.global_position
			} else {
				target_pos = enemy.global_position
			}
		} else {
			target_pos = origin_pos + Vector2(0, -20)
		}
		tween = create_tween().set_trans(Tween.TRANS_EXPO)
		tween.tween_property(node, "global_position", target_pos, 0.4)
		await tween.finished
		
		spinner.do_effect()
		tween = create_tween().set_trans(Tween.TRANS_BACK)
		tween.tween_property(node, "global_position", origin_pos, 0.5)
		tween.tween_property(card_slice, "scale", card_slice.scale/1.1, 0.3)
		await tween.finished
		
		await get_tree().create_timer(0.2).timeout
	}
	
	spin_btn.disabled = false
	spin_btn.visible = true
	state = State.PRESPIN
	for arrow in arrows.keys() {
		_detach_arrow(arrow)
		arrow.visible = false
	}
	for spinner in player_spinners.spinner_nodes + enemy_spinners.spinner_nodes {
		spinner.hide_slices()
	}
	
	GamestateManager.check_combat_result()
}

func _on_spin_btn_press() -> void {
	if state != State.PRESPIN: return
	#spin_btn.disabled = true
	#spin_btn.visible = false
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
		#target_btn.disabled = false
		target_btn.visible = true
	}
}

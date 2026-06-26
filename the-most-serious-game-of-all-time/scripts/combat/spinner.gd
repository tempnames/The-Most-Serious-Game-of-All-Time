class_name Spinner
extends Node2D

## Is the spinner controlled by the enemy?
@export var enemy: bool = false
## Radius of the spinner wheel
@export var size: float = 50
## Cards contained by the wheel
@export var data: SpinnerData

signal spun

## Multiplier to the speed at which the wheel slows down after being spun
@export var rotation_decay_mult := 2.0
## Strength of the motion blur
@export var motion_blur_strength := 0.2

# nodes
var wheel_bg: Polygon2D
var wheel: CascadeV3
var motion_blur: Polygon2D
var cap: Polygon2D
var speed_label: Label
var target_tugs: Array[TargetTug]
var spinner_lock: Option[TargetLock] = Option.none()
var spinner_lock_shape: Option[CircleShape2D] = Option.none()

var first_card_idx: int
var chosen_card_idx: Option[int]
var rotation_velocity := 0.0
var speed := 0
const SPEED_LABEL_SETTINGS = preload("uid://bajwyx2sc7o2k")

## Pretects from suppress
var block := 0
## Reduces next attack by amount
var suppress := 0

var queued_action: Callable

func _enter_tree() -> void {
	wheel_bg = Polygon2D.new()
	wheel_bg.color = Color.BLACK
	add_child(wheel_bg)
	
	wheel = CascadeV3.new()
	wheel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wheel.wait_a_frame = true
	wheel.start_on_ready = false
	add_child(wheel)
	
	motion_blur = Polygon2D.new()
	add_child(motion_blur)
	
	cap = Polygon2D.new()
	cap.color = Color.DARK_SLATE_GRAY
	add_child(cap)
	
	var speed_label_container := CenterContainer.new()
	speed_label_container.use_top_left = true
	speed_label = Label.new()
	speed_label.text = "?"
	speed_label.label_settings = SPEED_LABEL_SETTINGS
	speed_label_container.add_child(speed_label)
	add_child(speed_label_container)
	
	if enemy {
		var target_lock := TargetLock.new()
		target_lock.lock_type = Target.Type.SPINNER
		var target_lock_shape := CircleShape2D.new()
		target_lock_shape.radius = size
		target_lock.collision_shape = target_lock_shape
		target_lock.parent_ref = self # i'm sorry
		add_child(target_lock)
		spinner_lock = Option.some(target_lock)
		spinner_lock_shape = Option.some(target_lock_shape)
	}
}

func _ready() -> void {
	refresh_wheel()
	align_wheel()
	set_slice_alpha(1.0)
}

func _process(delta: float) -> void {
	if abs(rotation_velocity) > 0 {
		speed = randi_range(data.speed_min, data.speed_max)
		speed_label.text = str(speed)
		
		var rot_amt := TAU * delta
		if abs(rotation_velocity) > rot_amt {
			var sgn := 1.0
			if enemy {
				sgn = -1.0
			}
			rotation_velocity -= rot_amt * 0.5 * rotation_decay_mult
			wheel.rotation += sgn * rotation_velocity * delta * rotation_decay_mult
			rotation_velocity -= rot_amt * 0.5 * rotation_decay_mult
			motion_blur.color.a = motion_blur_strength * rotation_velocity/TAU
			upd_notches()
		} else {
			rotation_velocity = 0
			align_wheel()
			_spin_completed()
		}
	}
}

func align_wheel() -> void {
	var slice_ang := TAU/data.cards.size()
	var total_window_range := data.window * slice_ang
	
	wheel.rotation = -total_window_range/2 - first_card_idx * slice_ang
	if enemy {
		wheel.rotation += PI
	}
}

func spin() -> void {
	set_slice_alpha(0.4)
	for ttug in target_tugs {
		ttug.queue_free()
	}
	target_tugs.clear()
	block = 0
	suppress = 0
	queued_action = func() -> void { return }
	chosen_card_idx = Option.none()
	
	wheel.cascade_in()
	await wheel.cascade_in_chain_finished
	
	var old_card_idx := first_card_idx
	first_card_idx = randi_range(0, data.cards.size()-1)
	
	var card_offset: int
	if enemy {
		card_offset = posmod(first_card_idx - old_card_idx, data.cards.size())
	} else {
		card_offset = posmod(old_card_idx - first_card_idx, data.cards.size())
	}
	var card_ang := TAU/data.cards.size()
	var no_op_cycles := 4
	# Integral magic
	const magic_const = 2*sqrt(PI)
	rotation_velocity += magic_const * sqrt(card_ang * card_offset + TAU * no_op_cycles)
}

func _spin_completed() -> void {
	motion_blur.color.a = 0
	for i in range(data.window) {
		var slice_idx := (first_card_idx + i) % data.cards.size()
		var tentative_slice := wheel.get_child(slice_idx)
		if tentative_slice is not Polygon2D {
			continue
		}
		var slice := tentative_slice as Polygon2D
		slice.color.a = 1
		
		if not enemy {
			var tug := TargetTug.new()
			tug.global_rotation = wheel.rotation + (slice_idx + 0.5) * TAU/data.cards.size()
			tug.position = size * Vector2.from_angle(tug.global_rotation)
			tug.valid_targets = data.cards[slice_idx].targets
			target_tugs.push_back(tug)
			add_child(tug)
			tug.target_registered.connect(card_targeted.bind(Option.some(tug), slice_idx))
		}
	}
	
	spun.emit()
}

func dmg_block(blk: int) -> void {
	block += blk
}

func dmg_suppress(sprs: int) -> void {
	var blocked_suppress := mini(block, sprs)
	suppress += sprs - blocked_suppress
	block -= blocked_suppress
}

func hide_slices() -> void {
	wheel.cascade_out()
}

func card_targeted(potential_combatant: Option[Combatant], potential_spinner: Option[Spinner], tug: Option[TargetTug], card_idx: int) -> void {
	# Detach any others, only one tug is allowed to be active at once
	if tug.is_some() {
		var c_tug := tug.unwrap_unchecked()
		for other_tug in target_tugs {
			if other_tug == c_tug:
				continue
			other_tug.detach_arrow.emit()
		}
	}
	var card := data.cards[card_idx]
	var relation: Effect.Team
	if enemy {
		if potential_combatant.is_some() and potential_combatant.unwrap_unchecked() is Player or (
		   potential_spinner  .is_some() and not potential_spinner.unwrap_unchecked().enemy
		) {
			relation = Effect.Team.FOE
		} else {
			relation = Effect.Team.FRIEND
		}
	} else {
		if potential_combatant.is_some() and potential_combatant.unwrap_unchecked() is Player or (
		   potential_spinner  .is_some() and not potential_spinner.unwrap_unchecked().enemy
		) {
			relation = Effect.Team.FRIEND
		} else {
			relation = Effect.Team.FOE
		}
	}
	# Not sure about exact capture rules so anything that shouldn't be captured
	# from the current scope and instead from the caller's scope is explicitly
	# parameterized
	# —Hannah
	queued_action = func(slf: Spinner, gsm: GamestateManager) -> void {
		var effect_data := Effect.ExtraData.new()
		effect_data.blocked = slf.suppress
		if slf.enemy {
			effect_data.atk_mult = 1.0
			effect_data.blk_mult = 1.0
		} else {
			effect_data.atk_mult = gsm.atk_mult
			effect_data.blk_mult = gsm.blk_mult
		}
		for effect in card.effects {
			effect.resolve_effect(
				relation,
				potential_combatant,
				potential_spinner,
				effect_data
			)
		}
	}
	chosen_card_idx = Option.some(card_idx)
}

func roll_effect() -> void {
	if chosen_card_idx.is_none() { return }
	var c_card_idx = chosen_card_idx.unwrap_unchecked()
	var i := 0
	for effect in data.cards[c_card_idx].effects {
		effect.roll()
		var notch := wheel.get_child(c_card_idx).get_child(i)
		notch.cur_roll = effect.cur_roll
		notch.show_roll()
		i += 1
	}
}

func do_effect() -> void {
	if chosen_card_idx.is_none() { return }
	var c_card_idx = chosen_card_idx.unwrap_unchecked()
	queued_action.call(self, GamestateManager)
	for notch in wheel.get_child(c_card_idx).get_children() {
		notch.hide_roll()
	}
}

func set_slice_alpha(a: float) -> void {
	for tentative_slice in wheel.get_children() {
		if tentative_slice is not Polygon2D {
			continue
		}
		var slice := tentative_slice as Polygon2D
		slice.color.a = a
	}
}

## Only adjust the polygon points
## for UI adaptive resizing
## SHOULD NEVER ADD OR REMOVE NODES [expensive]
func resize_wheel() -> void {
	upd_poly_circle(wheel_bg, size)
	upd_poly_circle(motion_blur, size)
	upd_poly_circle(cap, size/3)
	
	spinner_lock_shape.and_then(func(shape: CircleShape2D) {
		shape.radius = size
	})
	
	# For the individual slices
	var card_amt := data.cards.size()
	var slice_size := TAU/card_amt
	var notch_size := 36
	var idx := 0
	for tentative_slice in wheel.get_children() {
		if tentative_slice is not Polygon2D {
			continue
		}
		var slice := tentative_slice as Polygon2D
		
		# Need to store polygon arrays in a seperate variable and then set them
		# otherwise they won't be saved
		var temp_points: Array[Vector2]
		
		# Slice tip
		temp_points.append(Vector2.ZERO)
		# Edge
		@warning_ignore("integer_division") # Intended
		var ang_count := maxi(2, 100/card_amt)
		
		var ang_mult := slice_size/ang_count 
		var ang_offset := idx * slice_size
		for ang_i in range(ang_count) {
			var ang := ang_mult * ang_i + ang_offset
			temp_points.append(Vector2(
				cos(ang) * size,
				sin(ang) * size
			))
		}
		
		# Now we can finally re-add the array
		slice.polygon = temp_points
		
		idx += 1
	}
	upd_notches()
}

func upd_notches() -> void {
	var card_amt := data.cards.size()
	var slice_size := TAU/card_amt
	var notch_size := 52
	var idx := 0
	for tentative_slice in wheel.get_children() {
		if tentative_slice is not Polygon2D {
			continue
		}
		var slice := tentative_slice as Polygon2D
		
		var ang_offset := (idx + 0.5) * slice_size
		
		var notch_pos = 32
		var angle := ang_offset
		for notch in slice.get_children() {
			notch.global_position = wheel.global_position + Vector2(
				cos(angle + wheel.rotation) * (size - notch_pos),
				sin(angle + wheel.rotation) * (size - notch_pos)
			)
			notch.rotation = angle
			if enemy {
				notch.rotation += PI
			}
			notch_pos += notch_size
		}
		
		idx += 1
	}
}

func upd_poly_circle(polygon: Polygon2D, radius: float) -> void {
	var temp_points: Array[Vector2]
	
	var ang_count = 100
	var ang_mult = TAU/ang_count 
	for ang_i in range(ang_count) {
		var ang = ang_mult * ang_i
		temp_points.append(Vector2(
			cos(ang) * radius,
			sin(ang) * radius
		))
	}
	
	# Now we can finally re-add the array
	polygon.polygon = temp_points
}

## Recreate the entire spinner
func refresh_wheel() -> void {
	for child in wheel.get_children() {
		child.queue_free()
	}
	
	var avg_color := Oklab.new()
	var card_amt := data.cards.size()
	var slice_size := TAU/card_amt
	var notch_size := 32
	var i := 0
	for card in data.cards {
		var slice := Polygon2D.new()
		slice.color = card.color
		wheel.add_child(slice)
		var angle = (i+0.5) * slice_size
		for effect in card.effects {
			var notch: Option[Polygon2D] = Option.none()
			if effect.effect_type == Effect.Type.ATTACK {
				var c_notch: AttackNotch = preload("uid://b2kr0g2ap0i4h").instantiate()
				c_notch.roll_min = effect.roll_min
				c_notch.roll_max = effect.roll_max
				notch = Option.some(c_notch)
			} elif effect.effect_type == Effect.Type.DEFEND {
				var c_notch: DefenseNotch = preload("uid://bowhqmkisepv5").instantiate()
				c_notch.roll_min = effect.roll_min
				c_notch.roll_max = effect.roll_max
				c_notch.bonus = effect.generic_param_1
				notch = Option.some(c_notch)
			}
			if notch.is_some() {
				var c_notch := notch.unwrap_unchecked()
				slice.add_child(c_notch)
			}
		}
		
		var new_color := Oklab.from_color(card.color)
		avg_color.L += new_color.L
		avg_color.a += new_color.a
		avg_color.b += new_color.b
		i += 1
	}
	avg_color.L /= i
	avg_color.a /= i
	avg_color.b /= i
	
	motion_blur.color = avg_color.to_color()
	motion_blur.color.a = 0
	
	resize_wheel()
}

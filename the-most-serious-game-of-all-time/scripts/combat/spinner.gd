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
var wheel: Node2D
var motion_blur: Polygon2D
var cap: Polygon2D
var speed_label: Label
var target_tugs: Array[TargetTug]

var first_card_idx: int
var rotation_velocity := 0.0
var speed := 0
const SPEED_LABEL_SETTINGS = preload("uid://bajwyx2sc7o2k")

func _enter_tree() -> void {
	wheel_bg = Polygon2D.new()
	wheel_bg.color = Color.BLACK
	add_child(wheel_bg)
	
	wheel = Node2D.new()
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
			wheel.rotate(sgn * rotation_velocity * delta * rotation_decay_mult)
			rotation_velocity -= rot_amt * 0.5 * rotation_decay_mult
			motion_blur.color.a = motion_blur_strength * rotation_velocity/TAU
		} else {
			rotation_velocity = 0
			align_wheel()
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
					tug.global_rotation = wheel.global_rotation + (slice_idx + 0.5) * TAU/data.cards.size()
					tug.position = size * Vector2.from_angle(tug.global_rotation)
					target_tugs.push_back(tug)
					add_child(tug)
				}
			}
			
			spun.emit()
		}
	}
	if Input.is_action_just_pressed("test") {
		spin()
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
	
	var old_card_idx := first_card_idx
	first_card_idx = randi_range(0, data.cards.size())
	
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
func resize_wheel() -> void {
	upd_poly_circle(wheel_bg, size)
	upd_poly_circle(motion_blur, size)
	upd_poly_circle(cap, size/3)
	
	# For the individual slices
	var card_amt := data.cards.size()
	var slice_size := TAU/card_amt
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
		var ang_count = maxi(2, 100/card_amt)
		
		var ang_mult = slice_size/ang_count 
		var ang_offset = idx * slice_size
		for ang_i in range(ang_count) {
			var ang = ang_mult * ang_i + ang_offset
			temp_points.append(Vector2(
				cos(ang) * size,
				sin(ang) * size
			))
		}
		
		# Now we can finally re-add the array
		slice.polygon = temp_points
		
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
	var col_count := 0
	for card in data.cards {
		var slice := Polygon2D.new()
		slice.color = card.color
		wheel.add_child(slice)
		
		var new_color := Oklab.from_color(card.color)
		avg_color.L += new_color.L
		avg_color.a += new_color.a
		avg_color.b += new_color.b
		col_count += 1
	}
	avg_color.L /= col_count
	avg_color.a /= col_count
	avg_color.b /= col_count
	
	motion_blur.color = avg_color.to_color()
	motion_blur.color.a = 0
	
	resize_wheel()
}

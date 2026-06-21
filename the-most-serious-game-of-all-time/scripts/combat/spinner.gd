class_name Spinner
extends Node2D

## Should the spinner point left instead of right?
@export var left: bool = false
## Radius of the spinner wheel
@export var size: float = 50
## Cards contained by the wheel
@export var data: SpinnerData
## Multiplier to the speed at which the wheel slows down after being spun
@export var rotation_decay_mult := 2.0
## Strength of the motion blur
@export var motion_blur_strength := 0.2

# nodes
var wheel: Node2D
var motion_blur: Polygon2D

var first_card_idx: int
var rotation_velocity := 0.0

func _enter_tree() -> void {
	wheel = Node2D.new()
	add_child(wheel)
	
	motion_blur = Polygon2D.new()
	
	add_child(motion_blur)
}

func _ready() -> void {
	refresh_wheel()
	align_wheel()
}

func _process(delta: float) -> void {
	if abs(rotation_velocity) > 0 {
		var rot_amt := TAU * delta
		if abs(rotation_velocity) > rot_amt {
			rotation_velocity -= rot_amt * 0.5 * rotation_decay_mult
			rotate(rotation_velocity * delta * rotation_decay_mult)
			rotation_velocity -= rot_amt * 0.5 * rotation_decay_mult
			motion_blur.color.a = motion_blur_strength * rotation_velocity/TAU
		} else {
			rotation_velocity = 0
			align_wheel()
			motion_blur.color.a = 0
		}
	}
	if Input.is_action_just_pressed("test") {
		spin()
	}
}

func align_wheel() -> void {
	var slice_ang := TAU/data.cards.size()
	var total_window_range := data.window * slice_ang
	rotation = PI - total_window_range/2 + first_card_idx * slice_ang
}

func spin() -> void {
	var old_card_idx := first_card_idx
	first_card_idx = randi_range(0, data.cards.size())
	
	var card_offset := posmod(first_card_idx - old_card_idx, data.cards.size())
	var card_ang := TAU/data.cards.size()
	var no_op_cycles := 4
	# Integral magic
	const magic_const = 2*sqrt(PI)
	rotation_velocity += magic_const * sqrt(card_ang * card_offset + TAU * no_op_cycles)
}

## Only adjust the polygon points
## for UI adaptive resizing
func resize_wheel() -> void {
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
	
	# For the motion blur
	# Need to store polygon arrays in a seperate variable and then set them
	if true {
		var temp_points: Array[Vector2]
		
		var ang_count = 100
		var ang_mult = TAU/ang_count 
		for ang_i in range(ang_count) {
			var ang = ang_mult * ang_i
			temp_points.append(Vector2(
				cos(ang) * size,
				sin(ang) * size
			))
		}
		
		# Now we can finally re-add the array
		motion_blur.polygon = temp_points
	}
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

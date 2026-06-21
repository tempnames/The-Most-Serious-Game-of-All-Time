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
var wheel: Node2D
var first_card_idx: int
var rotation_velocity := 0.0


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
		} else {
			rotation_velocity = 0
			align_wheel()
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

## Recreate the entire spinner
func refresh_wheel() -> void {
	if wheel == null {
		wheel = Node2D.new()
		add_child(wheel)
	}
	
	for child in wheel.get_children() {
		child.queue_free()
	}
	
	for card in data.cards {
		var slice := Polygon2D.new()
		slice.color = card.color
		wheel.add_child(slice)
	}
	
	resize_wheel()
}

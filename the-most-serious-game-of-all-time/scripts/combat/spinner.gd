class_name Spinner
extends Node2D

## Should the spinner point left instead of right?
@export var left: bool = false
## Radius of the spinner wheel
@export var size: float = 50
## Cards contained by the wheel
@export var data: SpinnerData
var wheel: Node2D


func _ready() -> void {
	refresh_wheel()
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

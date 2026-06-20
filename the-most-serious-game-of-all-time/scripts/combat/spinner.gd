class_name Spinner
extends Node2D

## Radius of the spinner wheel
@export var size: float = 50
## Cards contained by the wheel
@export var data: SpinnerData
var wheel: Node2D

func _ready() -> void {
	refresh_wheel()
}

func refresh_wheel() -> void {
	if wheel == null {
		wheel = Node2D.new()
		add_child(wheel)
	}
	
	for child in wheel.get_children() {
		child.queue_free()
	}
	
	var card_amt := data.cards.size()
	var slice_size := TAU/card_amt
	for idx in range(card_amt) {
		var card = data.cards[idx]
		var slice := Polygon2D.new()
		
		# Need to store polygon arrays in a seperate variable and then set them
		# otherwise they won't be saved
		var temp_points: Array[Vector2]
		var temp_colors: Array[Color]
		
		# Slice tip
		temp_points.append(Vector2.ZERO)
		temp_colors.append(Color.BLACK)
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
			temp_colors.append(card.color)
		}
		
		# Now we can finally re-add the array
		slice.polygon = temp_points
		slice.vertex_colors = temp_colors
		
		wheel.add_child(slice)
	}
}

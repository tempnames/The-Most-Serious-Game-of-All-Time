class_name AttackNotch
extends Polygon2D

@export var roll_min: int = 1
@export var roll_max: int = 8
@export var cur_roll: int

func _ready() -> void {
	hide_roll()
}

func show_roll() {
	$Rolled.text = str(cur_roll)
	$Values.visible = false
	$Rolled.visible = true
}

func hide_roll() {
	$Values.text = str(roll_min) + '~' + str(roll_max)
	$Rolled.visible = false
	$Values.visible = true
}

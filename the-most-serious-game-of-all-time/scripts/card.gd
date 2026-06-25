class_name Card
extends Resource

## Color of the card and its segment on the wheel
@export var color: Color
## Valid targets for the card
@export var targets: Target.Type
## Effects the card performs on resolution
@export var effects: Array[Effect]

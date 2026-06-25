class_name HealthBar
extends Sprite2D

@export var health := 1.0:
	set(new_val):
		(material as ShaderMaterial).set_shader_parameter("HealthPercent", new_val)
		health = new_val

func _ready() -> void {
	health = health
}

class_name HealthBar
extends Sprite2D

func set_health(val: float) {
	(material as ShaderMaterial).set_shader_parameter("HealthPercent", val)
}

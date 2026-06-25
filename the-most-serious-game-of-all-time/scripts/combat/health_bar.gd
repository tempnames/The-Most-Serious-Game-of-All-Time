class_name HealthBar
extends Sprite2D

func set_health(val) {
	(material as ShaderMaterial).set_shader_parameter("HealthPercent", val)
}

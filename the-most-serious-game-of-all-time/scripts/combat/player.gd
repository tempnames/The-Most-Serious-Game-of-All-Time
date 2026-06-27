class_name Player
extends Combatant

var block := 0

func _enter_tree() -> void {
	super()
	lock.lock_type = Target.Type.SELF
	lock.parent_ref = self # i'm sorry
}

func _ready() -> void {
	attack_for(0)
}

func attack_for(damage: int) -> void {
	var applied_block := mini(block, damage)
	GamestateManager.health -= maxi(0, damage-applied_block)
	block -= applied_block
	var tween := create_tween().set_trans(Tween.TRANS_EXPO)
	tween.tween_method(health_bar.set_health,
		(health_bar.material as ShaderMaterial).get_shader_parameter(&"HealthPercent"),
		GamestateManager.health as float / GamestateManager.max_health as float,
		1
	)
}

func clear_block() -> void {
	block = 0
}

func gain_block(b: int) -> void {
	block += b
}

class_name Player
extends Combatant

var block := 0

func _enter_tree() -> void {
	super()
	lock.lock_type = Target.Type.SELF
	lock.parent_ref = self # i'm sorry
}

func attack_for(damage: int) -> void {
	var applied_block := mini(block, damage)
	GamestateManager.health -= maxi(0, damage-applied_block)
	block -= applied_block
	health_bar.set_health(GamestateManager.health / GamestateManager.max_health)
}

func gain_block(b: int) -> void {
	block += b
}

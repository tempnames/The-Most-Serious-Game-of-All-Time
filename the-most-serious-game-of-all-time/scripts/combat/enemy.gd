class_name Enemy
extends Combatant

func _enter_tree() -> void {
	super()
	lock.lock_type = Target.Type.ENEMY
	lock.parent_ref = self # i'm sorry
}

func _ready() -> void {
	texture = GamestateManager.enemy_data.sprite
	GamestateManager.enemy_instance.health = GamestateManager.enemy_data.max_health
}

func attack_for(damage: int) -> void {
	print(damage)
	print(GamestateManager.enemy_instance.health as float / GamestateManager.enemy_data.max_health as float)
	var applied_block := mini(GamestateManager.enemy_instance.block, damage)
	GamestateManager.enemy_instance.health -= maxi(0, damage-applied_block)
	GamestateManager.enemy_instance.block -= applied_block
	health_bar.set_health(GamestateManager.enemy_instance.health as float / GamestateManager.enemy_data.max_health as float)
}

func gain_block(block: int) -> void {
	GamestateManager.enemy_instance.block += block
}

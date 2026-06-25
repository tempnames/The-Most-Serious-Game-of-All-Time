class_name Enemy
extends Combatant

func _enter_tree() -> void {
	super()
	lock.lock_type = Target.Type.ENEMY
}

func _ready() -> void {
	texture = GamestateManager.current_enemy.sprite
}

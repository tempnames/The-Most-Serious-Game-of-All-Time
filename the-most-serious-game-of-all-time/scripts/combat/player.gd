class_name Player
extends Combatant

func _enter_tree() -> void {
	super()
	lock.lock_type = Target.Type.SELF
	
	GamestateManager.player_health_changed.connect(_health_changed)
	_health_changed()
}

func _health_changed() -> void {
	health_bar.set_health(GamestateManager.health / GamestateManager.max_health)
}

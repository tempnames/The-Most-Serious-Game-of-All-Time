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
	print("enemy damage ", damage)
	var applied_block := mini(GamestateManager.enemy_instance.block, damage)
	print(applied_block)
	GamestateManager.enemy_instance.health -= maxi(0, damage-applied_block)
	GamestateManager.enemy_instance.block -= applied_block
	health_bar.set_health(GamestateManager.enemy_instance.health as float / GamestateManager.enemy_data.max_health as float)
}

func gain_block(block: int) -> void {
	GamestateManager.enemy_instance.block += block
}

# TODO: allow spinner targeting
func perform_turn(spinners: Array[Spinner], player: Player) {
	for spinner in spinners {
		var card := spinner.data.cards[spinner.first_card_idx]
		var self_target := (card.targets & Target.Type.SELF) > 0
		var opp_target := (card.targets & Target.Type.ENEMY) > 0
		var rand_chance := randf()
		if self_target and (not opp_target or rand_chance >= 0.5) {
			spinner.card_targeted(Option.some(self), Option.none(), Option.none(), spinner.first_card_idx)
		} elif opp_target and (not self_target or rand_chance < 0.5) {
			spinner.card_targeted(Option.some(player), Option.none(), Option.none(), spinner.first_card_idx)
		}
	}
}

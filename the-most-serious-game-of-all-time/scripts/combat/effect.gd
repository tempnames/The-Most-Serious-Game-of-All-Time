class_name Effect
extends Resource

enum Team {
	FRIEND,
	FOE
}

enum Type {
	## Roll for damage value
	## Uses: roll_min, roll_max
	ATTACK,
	## Roll for defence value
	## Generic Param 1 is the amount of additional defense
	## provided by targetting an enemy spinner
	## Uses: roll_min, roll_max, generic_param_1
	DEFEND
}

class ExtraData {
	var blocked: int = 0
	var atk_mult: float = 1.0
	var blk_mult: float = 1.0
}

@export var effect_type: Type
## General-purpose stats whose meaning depends on the effect type
@export_category("Stats")
@export var roll_min: int = 1
@export var roll_max: int = 8
@export var generic_param_1: int = 0
@export_category("Readonly")
@export var cur_roll: int

# I CRAVE proper sum types
# —Hannah

func resolve_effect(
	relation: Team,
	combatant_target: Option[Combatant],
	spinner_target: Option[Spinner],
	data: ExtraData
) {
	if relation == Team.FRIEND {
		if combatant_target.is_some() {
			var target := combatant_target.unwrap_unchecked()
			if effect_type == Type.ATTACK {
				pass
			} elif effect_type == Type.DEFEND {
				target.gain_block(roundi(cur_roll as float * data.blk_mult))
			}
		}
		if spinner_target.is_some() {
			var target := spinner_target.unwrap_unchecked()
			if effect_type == Type.ATTACK {
				pass
			} elif effect_type == Type.DEFEND {
				pass
			}
		}
	} else {
		if combatant_target.is_some() {
			var target := combatant_target.unwrap_unchecked()
			if effect_type == Type.ATTACK {
				target.attack_for(cur_roll - data.blocked)
			} elif effect_type == Type.DEFEND {
				pass
			}
		}
		if spinner_target.is_some() {
			var target := spinner_target.unwrap_unchecked()
			if effect_type == Type.ATTACK {
				pass
			} elif effect_type == Type.DEFEND {
				target.dmg_suppress(roundi(cur_roll as float * data.blk_mult) + generic_param_1)
			}
		}
	}
}

func roll() -> void {
	cur_roll = randi_range(roll_min, roll_max)
}

class_name Target
extends RefCounted

## Can be combined
## Target.Type.SELF | Target.Type.SPINNER
enum Type {
	NONE = 0,
	SELF = 1,
	ENEMY = 2,
	SELF_AND_ENEMY,
	SPINNER = 4,
	SELF_AND_SPINNER,
	ENEMY_AND_SPINNER,
	ALL
}

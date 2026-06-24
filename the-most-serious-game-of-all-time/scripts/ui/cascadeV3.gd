class_name CascadeV3 extends Control

signal cascade_in_chain_started
signal cascade_in_chain_finished

signal cascade_out_chain_started
signal cascade_out_chain_finished

signal cascade_in_started_for_node(node: Node)
signal cascade_in_finished_for_node(node: Node)

signal cascade_out_started_for_node(node: Node)
signal cascade_out_finished_for_node(node: Node)

@export var start_on_ready := true
@export var tween_in_time := 0.3
@export var stagger := 0.1
@export var easing := Tween.EaseType.EASE_OUT
@export var trans := Tween.TransitionType.TRANS_EXPO
@export var wait_a_frame := false
@export var affect_offsets_instead := false


var _node_to_position_map: Dictionary[Node, Vector2]
var _node_to_scale_map: Dictionary[Node, Vector2]

func _get_nodes_in_map() -> Array[Node]:
	return _node_to_position_map.keys()

func _save_position(node: Node) -> void:
	if _should_use_offsets_instead_for(node):
		_node_to_position_map[node] = node.offset_transform_position
		return
	
	_node_to_position_map[node] = node.position

func _save_scale(node: Node) -> void:
	if _should_use_offsets_instead_for(node):
		_node_to_scale_map[node] = node.offset_transform_scale
		return
	
	_node_to_scale_map[node] = node.scale

func _implements_transform_trait(node: Node) -> bool:
	return &"scale" in node

func _try_save_position(node: Node) -> void:
	if _implements_transform_trait(node):
		_save_position(node)

func _try_save_scale(node: Node) -> void:
	if _implements_transform_trait(node):
		_save_scale(node)

func _should_use_offsets_instead_for(node: Node) -> bool:
	return affect_offsets_instead and node is Control \
		and node.offset_transform_enabled

func _set_scale_for(node: Node, target_scale: Vector2) -> void:
	if _should_use_offsets_instead_for(node):
		node.offset_transform_scale = target_scale
		return
	
	node.scale = target_scale

func _set_pos_for(node: Node, target_pos: Vector2) -> void:
	if _should_use_offsets_instead_for(node):
		node.offset_transform_position = target_pos
		return
	
	node.position = target_pos

func _reset_state() -> void:
	for node in _get_nodes_in_map():
		_set_scale_for(node, Vector2.ZERO)
		node.hide()

func _initialise() -> void:
	for child in get_children():
		_try_save_position(child)
		_try_save_scale(child)

func _create_subtween_step() -> Tween:
	return create_tween().set_ease(easing).set_trans(trans).set_parallel(true)

func _pos_reflection_key_from(node: Node) -> NodePath:
	return ^"offset_transform_position"                         \
		if _should_use_offsets_instead_for(node)                \
		else ^"position"

func _scale_reflection_key_from(node: Node) -> NodePath:
	return ^"offset_transform_scale"                            \
		if _should_use_offsets_instead_for(node)                \
		else ^"scale"

func _subtween_hitzone_in(node: Node, delay: float) -> Tween:
	node.show()
	var target_position := _node_to_position_map[node]
	var target_scale := _node_to_scale_map[node]
	var pos_key := _pos_reflection_key_from(node)
	var scale_key := _scale_reflection_key_from(node)
	var t := _create_subtween_step()
	t.tween_callback(cascade_in_started_for_node.emit.bind(node))
	t.tween_property(node, pos_key, target_position, tween_in_time * 0.5).set_delay(delay)
	t.tween_property(node, scale_key, target_scale, tween_in_time).set_delay(delay)
	t.chain().tween_callback(cascade_in_finished_for_node.emit.bind(node))
	return t

func _subtween_hitzone_out(node: Node) -> Tween:
	var pos := _node_to_position_map[node]
	var pos_key := _pos_reflection_key_from(node)
	var scale_key := _scale_reflection_key_from(node)
	var target_pos := pos + Vector2(sin(pos.x) * 100, randf_range(-30, 30))
	var t := _create_subtween_step()
	t.tween_callback(cascade_out_started_for_node.emit.bind(node))
	t.tween_property(node, pos_key, target_pos, maxf(tween_in_time * 0.7, 0.3))
	t.tween_property(node, scale_key, Vector2(-2, 0), maxf(tween_in_time * 0.7, 0.3))
	t.chain().tween_callback(cascade_out_finished_for_node.emit.bind(node))
	t.chain().tween_callback(node.hide)
	return t

##scatter the units around, squish them into Vec(0,-2).
func _hitzone_scatter_pos(arr: Array[Node]) -> Array[Node]:
	for unit in arr:
		var original_position := _node_to_position_map[unit]
		_set_pos_for(unit, original_position + \
						Vector2(randf_range(-255, 55), randf_range(-55,55)))
		_set_scale_for(unit, Vector2(0, -2))
	return arr

##hitzone leaves everything's position in a haphazard state. this resets them back.
func _hitzone_reset_pos() -> void:
	for unit in _get_nodes_in_map():
		var original_pos := _node_to_position_map[unit]
		_set_pos_for(unit, original_pos)


var top_level_t: Tween
func reset_top_level_tween() -> void:
	if top_level_t: top_level_t.kill()
	top_level_t = create_tween()

func _cascade_engine_in() -> void:
	var nodes := _get_nodes_in_map()
	reset_top_level_tween()
	_hitzone_scatter_pos(nodes)
	
	var delay_so_far := 0.0
	top_level_t.tween_callback(cascade_in_chain_started.emit)
	
	for node in nodes:
		top_level_t.parallel().tween_subtween(_subtween_hitzone_in(node, delay_so_far))
		delay_so_far += stagger
	
	top_level_t.chain().tween_callback(cascade_in_chain_finished.emit)

func _cascade_engine_out() -> void:
	var nodes := _get_nodes_in_map()
	reset_top_level_tween()
	
	top_level_t.tween_callback(cascade_out_chain_started.emit)
	
	for node in nodes:
		top_level_t.parallel().tween_subtween(_subtween_hitzone_out(node))
	
	top_level_t.chain().tween_callback(_hitzone_reset_pos)
	top_level_t.chain().tween_callback(cascade_out_chain_finished.emit)

func cascade_in() -> void:
	_cascade_engine_in()

func cascade_out() -> void:
	_cascade_engine_out()

func stop() -> void:
	if top_level_t: top_level_t.kill()

func _ready() -> void:
	if wait_a_frame: await get_tree().process_frame
	_initialise()
	_reset_state()
	
	if start_on_ready: cascade_in()

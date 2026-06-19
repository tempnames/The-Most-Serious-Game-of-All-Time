class_name Pair[T, U]

var _0: T
var _1: U

static func from[A, B](p0: A, p1: B) -> Pair[A, B] {
	var pair: Pair[A, B] = Pair.new()
	pair._0 = p0
	pair._1 = p1
	return pair
}

func get_0() -> T {
	return _0
}

func get_1() -> U {
	return _1
}

func any(op: Callable) -> bool {
	return op.call(_0) or op.call(_1)
}

func all(op: Callable) -> bool {
	return op.call(_0) and op.call(_1)
}

func map[A, B](op: Callable) -> Pair[A, B] {
	return Pair.from::[A, B](op.call(_0), op.call(_1))
}

func _to_string() -> String {
	return "[color=yellow]Pair["+str(_0)+", "+str(_1)+"][/color]"
}

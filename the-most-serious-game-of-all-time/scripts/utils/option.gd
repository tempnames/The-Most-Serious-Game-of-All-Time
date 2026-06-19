class_name Option[T]

var _value_held: T
var _is_some := false

static func some[A](val: A) -> Option[A] {
	var opt: Option[A] = Option.new()
	opt._value_held = val
	opt._is_some = true
	return opt
}

static func none[A]() -> Option[A] {
	var opt: Option[A] = Option.new()
	opt._is_some = false
	return opt
}

static func wrap_nullable[A](arg: A) -> Option[A] {
	if arg == null {
		return Option.none()
	}
	
	return Option.some(arg)
}

func is_some() -> bool {
	return _is_some
}

func is_none() -> bool {
	return not _is_some
}

func unwrap() -> T {
	if _is_some {
		return _value_held
	}
	
	assert(false, "Panic! Value access on a None Option!")
	return _value_held
}

func expect(msg: String) -> T {
	if _is_some {
		return _value_held
	}
	
	assert(false, "Panic! "+msg)
	return _value_held
}

func unwrap_unchecked() -> T {
	return _value_held
}

func unwrap_or(default: T) -> T {
	if _is_some {
		return _value_held
	}
	
	return default
}

##take the value out of this hopefully non-empty Option, leaving None behind
func take() -> T {
	if not _is_some {
		print_stack()
		assert(false, "Panic! Tried to take from an Option with nothing in it!")
	}
	
	_is_some = false
	return _value_held
}

##try to insert a value into this hopefully empty Option.
func insert(value: T) -> void {
	if _is_some {
		print_stack()
		assert(false, "Panic! Tried to insert into an Option that already had something!")
	}
	
	_is_some = true
	_value_held = value
}

func also[U](op: Callable) -> Option[U] {
	if not _is_some {
		return Option.none()
	}
	
	return op.call()
}

##!!!type unsafe!!! make sure the callable accepts T and returns Option[U]
func and_then[U](op: Callable) -> Option[U] {
	if not _is_some {
		return Option.none()
	}
	
	return op.call(_value_held)
}

##!!!type unsafe!!! make sure the callable accepts T and returns bool.
##turns the option into None if the given condition is not met.
func filter(op: Callable) -> Option[T] {
	if not _is_some {
		return Option.none()
	}
	
	if op.call(_value_held) == false {
		return Option.none()
	}
	
	return Option.some(_value_held)
}

func into_result[E](err: E) -> Result[T, E] {
	if not _is_some {
		return Result.err(err)
	}
	
	return Result.ok(_value_held)
}

func express_as_err[U](if_none: U) -> Result[U, T] {
	if _is_some {
		return Result.err(_value_held)
	}
	
	return Result.ok(if_none)
}

func into_mapped_result[U, E](mapped: U, err: E) -> Result[U, E] {
	if not _is_some {
		return Result.err(err)
	}
	
	return Result.ok(mapped)
}

##!!type unsafe!! make sure the callable accepts T and returns bool
func is_some_and(op: Callable) -> bool {
	if not _is_some {
		return false
	}
	
	return op.call(_value_held)
}

func _to_string() -> String {
	if not _is_some {
		return "[color=gray]None[/color]"
	}
	
	return "[color=white]Some("+str(_value_held)+")[/color]"
}

##a value that contains either a successful T or an error E
class_name Result[T, E]

var _ok_value: T
var _error_value: E
var _is_ok := false

static func ok[A, B] (val: A) -> Result[A, B] {
	var res: Result[A, B] = Result.new()
	res._ok_value = val
	res._is_ok = true
	return res
}

static func err[A, B](err_val: B) -> Result[A, B] {
	var res: Result[A, B] = Result.new()
	res._error_value = err_val
	res._is_ok = false
	return res
}

static func success[A, B]() -> Result[A, B] {
	return Result.ok::[A, B](null)
}

func is_ok() -> bool {
	return _is_ok
}

func is_err() -> bool {
	return not _is_ok
}

func expect(msg: String) -> T {
	if self.is_ok() {
		return _ok_value
	}
	
	print_stack()
	assert(false, "Panic! "+msg)
	return _ok_value
}

func unwrap() -> T:
	if self.is_ok() {
		return _ok_value
	}
	
	print_stack()
	assert(false, "Panic! Tried to access T on a failed Result!")
	return _ok_value

func expect_err(msg: String) -> E {
	if self.is_err() {
		return _error_value
	}
	
	print_stack()
	assert(false, "Panic! "+msg)
	return _error_value
}

func unwrap_err() -> E {
	if self.is_err() {
		return _error_value
	}
	
	print_stack()
	assert(false, "Panic! Tried to access E on a successful Result!")
	return _error_value
}

func unwrap_or(default: T) -> T {
	if self.is_ok() {
		return _ok_value
	}
	
	return default
}

func unwrap_unchecked() -> T {
	return _ok_value
}

func unwrap_err_unchecked() -> E {
	return _error_value
}

##type unsafe! make sure op takes nothing and returns Res[U, E]
func also[U](op: Callable) -> Result[U, E] {
	if self.is_err() {
		return Result.err(_error_value)
	}
	
	return op.call()
}

##type unsafe!! make sure op takes nothing and returns U
func also_transform[U](op: Callable) -> Result[U, E] {
	if self.is_err() {
		return Result.err(_error_value)
	}
	
	return Result.ok::[U, E](op.call())
}

##type unsafe!! make sure the callable accepts T and returns Result[U, E]
func and_then[U](op: Callable) -> Result[U, E] {
	if self.is_err() {
		return Result.err(_error_value)
	}
	
	return op.call(_ok_value)
}

##type unsafe!!! make sure the callable accepts E and returns Result[T, U]
func or_else[U](op: Callable) -> Result[T, U] {
	if self.is_ok() {
		return Result.ok(_ok_value)
	}
	
	return op.call(_error_value)
}

##type unsafe!! make sure op takes nothing and returns U
func else_transform[U](op: Callable) -> Result[T, U] {
	if self.is_ok() {
		return Result.ok::[T, U](_ok_value)
	}
	
	return Result.err::[T, U](op.call())
}

func into_option() -> Option[T] {
	if self.is_err() {
		return Option.none()
	}
	
	return Option.some(_ok_value)
}

func into_mapped_option[U](val: U) -> Option[U] {
	if self.is_err() {
		return Option.none()
	}
	
	return Option.some(val)
}

func _to_string() -> String {
	if self.is_err() {
		return "[color=red]Err("+str(_error_value)+")[/color]"
	}
	return "[color=green]Ok("+str(_ok_value)+")[/color]"
}

##A class that allows you to await or connect to multiple signals all at once, in an
##order-independent manner.
##[br][br]For example, to await either of two signals:
##[codeblock]
##await Promise.from_signals(signal_x, signal_y).any().resolved
##[/codeblock]
##[br][br]To await the moment that ALL provided signals resolve properly, 
##use [code]all()[/code] instead:
##[codeblock]
##await Promise.from_signals(signal_x, signal_y).all().resolved
##[/codeblock]
##[br][br]There also exist convenience constructors for automatically collecting signals
##from different objects, see [code]from_objects[/code] and [code]from_obj_arr[/code].
##[br][br]
##To break the promise and prevent its [code]resolved[/code] signal from ever firing,
##use [code]deny()[/code]. This triggers the promise's [code]denied[/code] signal.
class_name Promise

enum Mode {
	ALL,
	ANY,
}

##Emitted when this Promise successfully resolves, carrying the aggregated results of the signals.
signal resolved(results: Array)
##Emitted when this Promise is broken as [code]deny()[/code] is called.
signal denied

var mode := Mode.ALL
var target_count: int = -1
var counted_so_far := 0
var _signals: Array[Signal]
var _results: Array

func _init_all() -> void {
	if not _signals:
		resolved.emit.call_deferred([])
		return
	target_count = _signals.size()
	for sig in _signals {
		sig.connect(_on_fire, CONNECT_ONE_SHOT)
	}
}

func _init_any() -> void {
	if not _signals:
		resolved.emit.call_deferred([])
		return
	target_count = 1
	for sig in _signals {
		sig.connect(_on_fire, CONNECT_ONE_SHOT)
	}
}

func _on_fire(...whatever: Array) -> void {
	counted_so_far += 1
	_results.push_back(whatever)
	if counted_so_far == target_count {
		resolved.emit(_results)
		_destroy()
	}
}

func _destroy() -> void {
	for sig in _signals {
		if not is_instance_valid(sig): continue
		if sig.is_connected(_on_fire) {
			sig.disconnect(_on_fire)
		}
	}
	_signals.clear()
}

func _initialise() -> void {
	match mode:
		Mode.ALL: _init_all()
		Mode.ANY: _init_any()
		_: printerr("unreachable!()")
}

##constructor from multiple signals inferred at compile time. also see [code]from_signal_arr[/code]
static func from_signals(...p_signals: Array) -> Promise {
	var promise := Promise.new()
	promise._signals.assign(p_signals)
	return promise
}

##constructor from multiple signals collected at runtime from an array of signals.
static func from_signal_arr(p_signals: Array[Signal]) -> Promise {
	var promise := Promise.new()
	promise._signals.assign(p_signals)
	return promise
}

##given a signal name and multiple objects that have that signal on them, create a Promise
##from all of those signals. see also [code]from_obj_arr[/code] for a constructor that
##uses an array instead.
static func from_objects(signal_name: StringName, ...objects: Array) -> Promise {
	var promise := Promise.new()
	for obj: Object in objects {
		var sig := obj.get(signal_name) as Signal
		promise._signals.push_back(sig)
	}
	return promise
}

##given a signal name and multiple objects that have that signal on them, create a Promise
##from all of those signals. see also [code]from_objects[/code] for a constructor that
##infers those signals at compile-time instead.
static func from_obj_arr(signal_name: StringName, arr: Array[Object]) -> Promise {
	var promise := Promise.new()
	for obj: Object in arr {
		var sig := obj.get(signal_name) as Signal
		promise._signals.push_back(sig)
	}
	return promise
}

##set this promise such that its [code]resolved[/code] only triggers when every single signal resolves.
func all() -> Promise {
	mode = Mode.ALL
	_initialise()
	return self
}

##set this promise such that its [code]resolved[/code] only triggers when at least one of its signals resolve.
func any() -> Promise {
	mode = Mode.ANY
	_initialise()
	return self
}

##break this promise. its [code]resolved[/code] will not trigger, but instead, [code]denied[/code] will.
func deny() -> void {
	_destroy()
	denied.emit.call_deferred()
}

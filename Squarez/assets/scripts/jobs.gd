class_name Jobs

enum {ALL, ANY}

signal completed

var _list := []
var _counter := 0
var _mode := ALL

func _init():
	pass

func _check() -> bool:
	if _mode == ANY:
		return true
	else:
		if _counter == len(_list):
			return true
	return false

func submit():
	_counter = _counter + 1
	if _check():
		completed.emit()

## As the following function is documented, even though its name starts with
func add(job):
	if job is Callable:
		add_callable(job)
	elif job is Signal:
		add_signal(job)

func add_callable(fun: Callable):
	_list.append(func():
		await fun.call()
		submit()
		)

func add_signal(sig: Signal):
	_list.append(func():
		await sig
		submit()
		)
		
func _call():
	for f in _list:
		f.call()

func _run():
	_call()
	if not _check():
		await completed

func clear():
	_list = []
	_counter = 0

func all():
	_mode = ALL
	await _run()
	
func any():
	_mode = ANY
	await _run()

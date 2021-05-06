extends Node

var best_time_deathless := -1
var best_time_checkpoints := -1
var checkpoints := false
var instant_death := false
var attempts := 0
var god_mode := false
const FILE_VERSION := 1

var start_time := -1
var victory_time := -1
var pause_start_time := -1

var last_environment := 'outside'
var restart_on_death := true
var save_state_data := {}
const SAVE_STATE_VERSION = 0

signal pause_changed(p)
signal mode_changed(m)
signal pause_header(h)
signal stats(s)
signal progress(p)

func _ready() -> void:
	pause_mode = PAUSE_MODE_PROCESS
	get_tree().set_auto_accept_quit(false)

	call_deferred('update_stats')
	call_deferred('set_pause', true)
	
	call_deferred('new_game', true)

	try_loading_setup()

	get_tree().call_deferred('call_group', 'checkpoint', 'set_enabled', checkpoints)
	call_deferred('emit_signal', 'mode_changed', checkpoints)


func try_loading_setup() -> void:
	var file := File.new()
	var err := file.open('user://data.json', File.READ)
	if not err:
		var parse_result := JSON.parse(file.get_as_text())
		file.close()
		if not (parse_result.error or typeof(parse_result.result) != TYPE_DICTIONARY):
			var data := (parse_result.result as Dictionary)
			var version := (data['file_version'] as int)
			if version >= 0:
				best_time_deathless = data['best_time_deathless'] as int
				best_time_checkpoints = data['best_time_checkpoints'] as int
				checkpoints = data['checkpoints'] as bool
				instant_death = data['instant_death'] as bool
			if version >= 1:
				god_mode = data['god_mode']

func try_loading_state():
	var file := File.new()
	var err := file.open('user://state.json', File.READ)
	if err:
		return
	var parse_result := JSON.parse(file.get_as_text())
	file.close()
	if parse_result.error or typeof(parse_result.result) != TYPE_DICTIONARY:
		return
	
	var result := (parse_result.result as Dictionary)
	if result['version'] != SAVE_STATE_VERSION:
		return
	var data := result['data'] as Dictionary
	for k in data.keys():
		var n := get_node_or_null(k)
		if n == null:
			push_warning("Discarding nonexistnet node\'s state: " + k)
		else:
			n.call_deferred('_load', data[k])
	last_environment = result['environment']
	start_time = OS.get_ticks_msec() - result['time']
	pause_start_time = result['time']
	restart_on_death = result['restart_on_death']
	

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_QUIT_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		save(true)


func save(q: bool = false) -> void:
	save_setup()
	save_state(q)

func save_setup() -> void:
	var file := File.new()
	if file.open('user://data.json', File.WRITE):
		return
	file.store_string(JSON.print({
		'best_time_deathless': best_time_deathless,
		'best_time_checkpoints': best_time_checkpoints,
		'checkpoints': checkpoints,
		'instant_death': instant_death,
		'god_mode': god_mode,
		'file_version': FILE_VERSION
	}))
	file.close()

func save_state(q: bool) -> void:
	save_state_data = {}
	get_tree().call_group('save', '_save')
	call_deferred('finish_save', q)

func finish_save(q: bool) -> void:
	var data := JSON.print({
		'version': SAVE_STATE_VERSION,
		'data': save_state_data,
		'environment': last_environment,
		'time': time(),
		'restart_on_death': restart_on_death
	}, '    ', true)
	var file := File.new()
	if file.open('user://state.json', File.WRITE):
		return
	file.store_string(data)
	file.close()
	if q:
		get_tree().quit()

func _input(event) -> void:
	if event.is_action_pressed('restart'):
		new_game()
		set_pause(false)
	if event.is_action_pressed('pause'):
		toggle_pause()
	
func format_time(time: int) -> String:
	if time == -1:
		return '99:99:99.999'

	var msec := '%03d' % (time % 1000)
	time /= 1000
	var sec := '%02d' % (time % 60)
	time /= 60
	var minutes := '%02d' % (time % 60)
	time /= 60
	var hours := '%02d' % (time)

	return hours + ':' + minutes + ':' + sec + '.' + msec

func new_game(load_state: bool = false):
	start_time = OS.get_ticks_msec()
	pause_start_time = -1
	victory_time = -1
	get_tree().call_group('new_game', 'new_game')
	last_environment = 'outside'
	restart_on_death = true
	if load_state:
		try_loading_state()
	set_environment(last_environment, true)

func time() -> int:
	if get_tree().paused:
		return pause_start_time
	return OS.get_ticks_msec() - start_time

func toggle_pause() -> void:
	set_pause(not get_tree().paused)

func set_pause(p: bool) -> void:
	if p == get_tree().paused:
		return
	if p:
		pause_start_time = time()
		get_tree().paused = p
	else:
		get_tree().paused = p
		if victory_time != -1:
			new_game()
		else:
			start_time += time() - pause_start_time
	if OS.get_name() == 'HTML5':
		save()
	emit_signal('pause_header', 'PAUSED')
	emit_signal('pause_changed', get_tree().paused)

func display_time() -> String:
	if victory_time != -1:
		return format_time(victory_time)
	return format_time(time())

func toggle_checkpoints() -> void:
	set_checkpoints(not checkpoints)

func set_checkpoints(c: bool, force: bool = false) -> void:
	if checkpoints == c and not force:
		return
	checkpoints = c
	get_tree().call_group('checkpoint', 'set_enabled', checkpoints)
	emit_signal('mode_changed', c)
	new_game()
	
func win() -> void:
	victory_time = time()
	if checkpoints:
		if best_time_checkpoints == -1:
			best_time_checkpoints = victory_time
		best_time_checkpoints = min(best_time_checkpoints, victory_time) as int 
	else:
		if best_time_deathless == -1:
			best_time_deathless = victory_time
		best_time_deathless = min(best_time_deathless, victory_time) as int
	update_stats()
	set_pause(true)
	emit_signal('pause_header', 'U WIN LOL')

func die() -> void:
	if not checkpoints and restart_on_death:
		new_game()
	Global.set_pause(not Global.instant_death)
	emit_signal('pause_header', 'U DEAD MATE')

func update_stats():
	emit_signal('stats', 'BEST CHAD TIME:   ' + format_time(best_time_deathless) + '\nBEST VIRGIN TIME: ' + format_time(best_time_checkpoints))

func set_environment(e: String, fast: bool = false):
	last_environment = e
	get_tree().call_group('environment', 'set_environment', e, fast)

extends Node

var best_time_deathless := -1
var best_time_checkpoints := -1
var checkpoints := false
var instant_death := false
var attempts := 0
const FILE_VERSION := 0

var start_time := -1
var victory_time := -1
var pause_start_time := -1

signal pause_changed(p)
signal mode_changed(m)
signal pause_header(h)
signal stats(s)

func _ready() -> void:
	pause_mode = PAUSE_MODE_PROCESS

	call_deferred('update_stats')
	call_deferred('set_pause', true)
	call_deferred('new_game')

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
				
	get_tree().call_deferred('call_group', 'checkpoint', 'set_enabled', checkpoints)
	call_deferred('emit_signal', 'mode_changed', checkpoints)

func _exit_tree() -> void:
	var file := File.new()
	var err := file.open('user://data.json', File.WRITE)
	if err:
		return
	file.store_string(JSON.print({
		'best_time_deathless': best_time_deathless,
		'best_time_checkpoints': best_time_checkpoints,
		'checkpoints': checkpoints,
		'instant_death': instant_death,
		'file_version': FILE_VERSION
	}))
	file.close()

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

func new_game():
	start_time = OS.get_ticks_msec()
	pause_start_time = -1
	victory_time = -1
	get_tree().call_group('new_game', 'new_game')

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
	if not checkpoints:
		new_game()
	Global.set_pause(not Global.instant_death)
	emit_signal('pause_header', 'U DEAD MATE')

func update_stats():
	emit_signal('stats', 'BEST CHAD TIME:   ' + format_time(best_time_deathless) + '\nBEST VIRGIN TIME: ' + format_time(best_time_checkpoints))

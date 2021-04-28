extends MarginContainer

var checkpoints := false
var mode_names := {
	true: 'VIRGIN',
	false: 'CHAD'
}

func _ready() -> void:
	$HUDContainer/HBoxContainer/ModeLabel.text = 'Game mode: %s' % mode_names[checkpoints]
	get_tree().call_deferred('call_group', 'checkpoint', 'set_enabled', checkpoints)

func _process(_delta: float) -> void:
	$HUDContainer/TimeLabel.text = _format_time($ViewportContainer/Viewport/Game.time())

func _input(event) -> void:
	if event.is_action_pressed('restart'):
		$HUDContainer/RestartButton.emit_signal('pressed')
	if event.is_action_pressed('change_mode'):
		$HUDContainer/HBoxContainer/ModeButton.emit_signal('pressed')
	if event is InputEventMouseMotion:
		if (event as InputEventMouseMotion).speed.length() >= 500:
			if not $HUDContainer.visible:
				$HUDContainer/AnimationPlayer.play('fade_in')
				$HUDContainer/HideTimer.start()


func _on_Game_victory() -> void:
	$HUDContainer/VictoryLabel.show()

func toggle_checkpoints():
	$HUDContainer/RestartButton.emit_signal('pressed')
	checkpoints = not checkpoints
	$HUDContainer/HBoxContainer/ModeLabel.text = 'Game mode: %s' % mode_names[checkpoints]
	get_tree().call_group('checkpoint', 'set_enabled', checkpoints)

func _on_RestartButton_pressed() -> void:
	$HUDContainer/VictoryLabel.hide()
	get_tree().paused = false

func _format_time(time: int) -> String:
	var msec := '%03d' % (time % 1000)
	time /= 1000
	var sec := '%02d' % (time % 60)
	time /= 60
	var minutes := '%02d' % (time % 60)
	time /= 60
	var hours := '%02d' % (time)

	return hours + ':' + minutes + ':' + sec + '.' + msec


func _on_HideTimer_timeout() -> void:
	$HUDContainer/AnimationPlayer.play('fade_out')

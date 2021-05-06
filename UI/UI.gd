extends MarginContainer

var mode_names := {
	true: 'VIRGIN',
	false: 'CHAD'
}

var instant_death_text := {
	true: 'INSTANT',
	false: 'PAUSE'
}

func _ready() -> void:
	$PausePanel.hide()
	var _tmp : int
	_tmp = Global.connect('pause_changed', self, '_on_pause_changed')
	_tmp = Global.connect('mode_changed', self, '_on_mode_changed')
	_tmp = Global.connect('pause_header', self, '_on_pause_header')
	_tmp = Global.connect('stats', self, '_on_stats')
	_tmp = Global.connect('progress', self, '_on_progress')
	$PausePanel/VBoxContainer/ModeButton.set_deferred('text', 'Game mode: %s' % mode_names[Global.checkpoints])
	$PausePanel/VBoxContainer/InstantDeathButton.set_deferred('text', 'Death: %s' % instant_death_text[Global.instant_death])

func _process(_delta: float) -> void:
	$MarginContainer/TimeLabel.text = Global.display_time()

func _input(event):
	if event is InputEventMouseMotion:
		if (event as InputEventMouseMotion).speed.length() >= 500:
			if not $HUDContainer.visible:
				$HUDContainer/AnimationPlayer.play('fade_in')
				$HUDContainer/HideTimer.start()


func _on_RestartButton_pressed() -> void:
	Global.new_game()
	Global.set_pause(false)


func _on_HideTimer_timeout() -> void:
	$HUDContainer/AnimationPlayer.play('fade_out')
	pass

func _on_PauseButton_pressed() -> void:
	Global.toggle_pause()

func _on_pause_changed(p: bool) -> void:
	$PausePanel.visible = p

func _on_ResumeButton_pressed() -> void:
	Global.toggle_pause()

func _on_mode_changed(m: bool) -> void:
	$PausePanel/VBoxContainer/ModeButton.text = 'Game mode: %s' % mode_names[m]

func _on_ModeButton_pressed() -> void:
	Global.toggle_checkpoints()


func _on_InstantDeathButton_pressed() -> void:
	Global.instant_death = not Global.instant_death
	$PausePanel/VBoxContainer/InstantDeathButton.text = 'Death: %s' % instant_death_text[Global.instant_death]

func _on_pause_header(h: String) -> void:
	$PausePanel/VBoxContainer/HeaderLabel.text = h

func _on_stats(s: String) -> void:
	$PausePanel/VBoxContainer/HBoxContainer/BestLabel.text = s

func _on_progress(p: float) -> void:
	$MarginContainer/ProgressLabel.text = str(floor(p * 100)) + '%'

func _on_ClearStatsButton_pressed() -> void:
	Global.best_time_checkpoints = -1
	Global.best_time_deathless = -1
	Global.update_stats()
	

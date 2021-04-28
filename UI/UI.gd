extends MarginContainer

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	$MarginContainer/TimeLabel.text = _format_time($ViewportContainer/Viewport/Game.time())

func _input(event) -> void:
	if event.is_action_pressed('restart') and get_tree().paused:
		_on_RestartButton_pressed()
		$ViewportContainer/Viewport/Game._on_RestartButton_pressed()

func _on_Game_victory() -> void:
	$CenterContainer/VictoryPopup/VBoxContainer/VictoryLabel.text = 'U WIN (time: ' + _format_time($ViewportContainer/Viewport/Game.victory_time) + ')'
	$CenterContainer/VictoryPopup.show()


func _on_RestartButton_pressed() -> void:
	$CenterContainer/VictoryPopup.hide()
	$CenterContainer/DeathPopup.hide()
	get_tree().paused = false


func _on_Game_death() -> void:
	$CenterContainer/DeathPopup.show()

func _format_time(time: int) -> String:
	var msec := '%03d' % (time % 1000)
	time /= 1000
	var sec := '%02d' % (time % 60)
	time /= 60
	var minutes := '%02d' % (time % 60)
	time /= 60
	var hours := '%02d' % (time)

	return hours + ':' + minutes + ':' + sec + '.' + msec

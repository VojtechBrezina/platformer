extends MarginContainer

func _ready() -> void:
	pass

func _on_Game_victory() -> void:
	$VictoryPopup.popup_centered()


func _on_RestartButton_pressed() -> void:
	$VictoryPopup.hide()
	$DeathPopup.hide()
	get_tree().paused = false


func _on_Game_death() -> void:
	$DeathPopup.popup_centered()

extends MarginContainer

func _ready() -> void:
	pass

func _on_Game_victory() -> void:
	$CenterContainer/VictoryPopup.show()


func _on_RestartButton_pressed() -> void:
	$CenterContainer/VictoryPopup.hide()
	$CenterContainer/DeathPopup.hide()
	get_tree().paused = false


func _on_Game_death() -> void:
	$CenterContainer/DeathPopup.show()

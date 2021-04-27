extends Node2D

signal victory
signal start
signal death

func _ready() -> void:
	call_deferred('emit_signal', 'start')


func _on_RestartButton_pressed() -> void:
	emit_signal('start')


func _on_Lever_body_entered(body: Node) -> void:
	if body == $Player:
		$Lever.state = !$Lever.state
		$Door.state = $Lever.state

func _on_VictoryWorm_body_entered(body: Node) -> void:
	if body == $Player:
		get_tree().paused = true
		emit_signal('victory')

func _on_Player_death() -> void:
	get_tree().paused = true
	emit_signal('death')


func _on_Spider_body_entered(body: Node) -> void:
	if body == $Player:
		get_tree().paused = true
		emit_signal('death')

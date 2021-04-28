extends Node2D

signal victory

var start_time := 0
var victory_time := 0

func _ready() -> void:
	get_tree().call_deferred('call_group', 'new_game', 'new_game')


func _on_RestartButton_pressed() -> void:
	get_tree().call_group('new_game', 'new_game')


func _on_Lever_body_entered(body: Node) -> void:
	if body == $Player:
		$Lever.state = !$Lever.state
		$Door.state = $Lever.state	



func _on_Spider_body_entered(body: Node) -> void:
	if body == $Player:
		get_tree().paused = true
		emit_signal('death')


func _on_Player_victory() -> void:
	get_tree().paused = true
	victory_time = time()
	emit_signal('victory')

func time() -> int:
	return OS.get_ticks_msec() - start_time

func new_game() -> void:
	start_time = OS.get_ticks_msec()

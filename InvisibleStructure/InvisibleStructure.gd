extends TileMap

var shown := false

func _ready() -> void:
	pass

func discover() -> void:
	if shown:
		return
	shown = true
	show()
	if is_in_group('deadly'):
		modulate = Color(1, 1, 1, 1)
	else:
		$AnimationPlayer.play('show')


func _on_Game_start() -> void:
	hide()
	shown = false
	modulate = Color(1, 1, 1, 0)

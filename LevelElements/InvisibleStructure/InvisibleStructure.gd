extends TileMap

var shown := false

func _ready() -> void:
	pass

func trigger() -> void:
	if shown:
		return
	occluder_light_mask = 1
	shown = true
	show()
	if is_in_group('deadly'):
		modulate = Color(1, 1, 1, 1)
	else:
		$AnimationPlayer.play('show')


func new_game() -> void:
	hide()
	occluder_light_mask = 0
	shown = false
	modulate = Color(1, 1, 1, 0)

func _save() -> void:
	Global.save_state_data[str(get_path())] = {
		'shown': shown
	}

func _load(data: Dictionary):
	if data['shown']:
		modulate = Color(1, 1, 1, 1)
		visible = true
		shown = true

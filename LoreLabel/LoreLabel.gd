extends Label

func _ready() -> void:
	pass

func trigger():
	if not visible:
		$AnimationPlayer.play('fade_in')

func new_game():
	visible = false
	$AnimationPlayer.stop()

func _save() -> void:
	Global.save_state_data[str(get_path())] = {
		'visible': visible
	}

func _load(data: Dictionary) -> void:
	visible = data['visible']

extends Area2D

var active := false
var enabled := false

export(String) var environment := 'outside'
export(bool) var level := false

var enbled_animations := {
	true: 'idle',
	false: 'disabled'
}

func _ready() -> void:
	pass

func trigger() -> void:
	if not active:
		active = true
		$Sprite/AnimationPlayer.play('active_level' if level else 'active')

func new_game() -> void:
	active = false
	$Sprite/AnimationPlayer.play(enbled_animations[enabled])

func set_enabled(e: bool) -> void:
	enabled = e
	$CollisionShape2D.disabled = not e
	if level:
		$Sprite/AnimationPlayer.play('level')
	else:
		$Sprite/AnimationPlayer.play(enbled_animations[e])

func _save() -> void:
	Global.save_state_data[str(get_path())] = {
		'active': active
	}

func _load(data: Dictionary) -> void:
	if data['active']:
		call_deferred('trigger')

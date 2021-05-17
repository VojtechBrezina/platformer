tool
extends Area2D

var active := false
var enabled := false

signal triggered

export(String, 'outside', 'cave') var environment := 'outside'
export(bool) var level := false setget _set_level

var enbled_animations := {
	true: 'idle',
	false: 'disabled'
}

func _ready() -> void:
	_update_editor()

func trigger() -> void:
	if not active and (enabled or level):
		active = true
		$Sprite/AnimationPlayer.play('active_level' if level else 'active')
		emit_signal('triggered')

func new_game() -> void:
	active = false
	if level:
		$Sprite/AnimationPlayer.play('level')
	else:
		$Sprite/AnimationPlayer.play(enbled_animations[enabled])

func set_enabled(e: bool) -> void:
	enabled = e or level
	$CollisionShape2D.disabled = not enabled
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

func _update_editor() -> void:
	if Engine.editor_hint:
		$Sprite/AnimationPlayer.play('level' if level else 'idle')

func _set_level(l: bool) -> void:
	level = l
	_update_editor()

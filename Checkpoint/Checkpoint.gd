extends Area2D

var active := false
var enabled := false

var enbled_animations := {
	true: 'idle',
	false: 'disabled'
}

func _ready() -> void:
	pass

func trigger() -> void:
	if not active:
		active = true
		$Sprite/AnimationPlayer.play('active')

func new_game() -> void:
	active = false
	$Sprite/AnimationPlayer.play(enbled_animations[enabled])

func set_enabled(e: bool) -> void:
	enabled = e
	$CollisionShape2D.disabled = not e
	$Sprite/AnimationPlayer.play(enbled_animations[e])

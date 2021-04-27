extends StaticBody2D

export var state := false setget _set_state, _get_state

const SPRITE_REGIONS := {
	false: Rect2(911, 30, 68, 111),
	true: Rect2(770, 30, 68, 111)
}

func _ready() -> void:
	pass

func _set_state(s: bool) -> void:
	if s != state:
		state = s
		$Sprite.region_rect = SPRITE_REGIONS[state]
		$CollisionShape2D.set_deferred('disabled', state)

func _get_state() -> bool:
	return state

func _on_Game_start() -> void:
	_set_state(false)

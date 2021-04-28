extends Area2D

const SPRITE_REGIONS := {
	false: Rect2(504, 216, 70, 70),
	true: Rect2(491, 0, 70, 70)
}

export var state := false setget _set_state, _get_state
signal state_changed(state)

func _ready() -> void:
	pass

func _set_state(s: bool) -> void:
	if s != state:
		emit_signal('state_changed', s)
		state = s
		$Sprite.region_rect = SPRITE_REGIONS[state]

func _set_state_safe(s: bool) -> void:
	if s != state:
		state = s
		$Sprite.region_rect = SPRITE_REGIONS[state]

func _get_state() -> bool:
	return state

func trigger() -> void:
	_set_state(!state)

func new_game() -> void:
	_set_state(false)

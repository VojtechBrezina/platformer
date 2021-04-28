extends PathFollow2D

var p_pos := Vector2()

func _ready() -> void:
	$Sprite/AnimationPlayer.play(("fly"))

func _physics_process(delta: float) -> void:
	offset = wrapf(offset + delta * 300, 0, (get_parent() as Path2D).curve.get_baked_length())
	$Sprite.flip_h = position.x - p_pos.x > 0
	p_pos = position


func new_game() -> void:
	offset = 0

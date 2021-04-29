extends PathFollow2D

onready var default_offset := offset

var p_pos := Vector2()

func _ready() -> void:
	$Sprite/AnimationPlayer.play('fly')

func _physics_process(delta: float) -> void:
	offset = wrapf(offset + delta * 400, 0, (get_parent() as Path2D).curve.get_baked_length())
	var x_vel :=position.x - p_pos.x
	if abs(x_vel) > 0.01:
		$Sprite.flip_h = x_vel > 0
	p_pos = position


func new_game() -> void:
	offset = default_offset

extends PathFollow2D

onready var default_offset := offset

var p_pos := Vector2()
onready var speed = 400 + rand_range(-50, 50)

func _ready() -> void:
	$Sprite/AnimationPlayer.play('fly')

func _physics_process(delta: float) -> void:
	offset = wrapf(offset + delta * speed, 0, (get_parent() as Path2D).curve.get_baked_length())
	var x_vel :=position.x - p_pos.x
	if abs(x_vel) > 0.01:
		$Sprite.flip_h = x_vel > 0
	p_pos = position


func new_game() -> void:
	offset = default_offset

func _save() -> void:
	Global.save_state_data[str(get_path())] = {
		'speed': speed,
		'offset': offset
	}

func _load(data: Dictionary) -> void:
	speed = float(data['speed'])
	offset = float(data['speed'])

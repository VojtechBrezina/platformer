extends KinematicBody2D

onready var animation_player := $AnimationPlayer

const WALK_SPEED := 500
const GRAVITY := 50
const JUMP_HEIGHT := 20
var velocity := Vector2(0, 0)

onready var default_position := position
onready var default_dir := -scale.x

onready var dir := default_dir

var on_wall := false

func _ready() -> void:
	animation_player.play('walk')


func _physics_process(_delta: float) -> void:
	velocity.x = WALK_SPEED * dir
	velocity.y += GRAVITY

	velocity = move_and_slide(velocity, Vector2.UP, false, 4, 0.8)
	if is_on_wall() and not on_wall:
		dir *= -1
		global_scale.x = -1 if dir else 1
		on_wall = true
		$WallTimer.start()
		
			
	
func new_game() -> void:
	position = default_position
	dir = default_dir
	$Sprite.flip_h = dir == 1


func _on_WallTimer_timeout() -> void:
	on_wall = false

func _save() -> void:
	Global.save_state_data[str(get_path())] = {
		'pos_x': position.x,
		'pos_y': position.y,
		'vel_x': velocity.x,
		'vel_y': velocity.y,
		'dir': dir
	}

func _load(data: Dictionary) -> void:
	position = Vector2(float(data['pos_x']), float(data['pos_y']))
	velocity = Vector2(float(data['vel_x']), float(data['vel_y']))
	dir = data['dir']
	if dir > 0:
		scale.x = -1
	

extends KinematicBody2D

onready var animation_player := $AnimationPlayer

const WALK_SPEED := 400
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

	velocity = move_and_slide(velocity, Vector2.UP, false, 10)
	if abs(velocity.x) == 0 and not on_wall:
		dir *= -1
		$Sprite.flip_h = dir == 1
		on_wall = true
		$WallTimer.start()
		
			
	
func new_game() -> void:
	position = default_position
	dir = default_dir
	$Sprite.flip_h = dir == 1


func _on_WallTimer_timeout() -> void:
	on_wall = false

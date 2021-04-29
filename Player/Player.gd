extends KinematicBody2D

onready var animation_player := $AnimationPlayer

const WALK_SPEED := 300
const GRAVITY := 50
const JUMP_HEIGHT := 20
var velocity := Vector2(0, 0)

var last_direction := 'right'

onready var default_position := position
onready var checkpoint_position := default_position


func _ready() -> void:
	animation_player.play('idle_right')


func _physics_process(_delta: float) -> void:
	var idle := true

	if Input.is_action_pressed('walk_left'):
		velocity.x = -WALK_SPEED
		idle = false
	elif Input.is_action_pressed('walk_right'):
		velocity.x = WALK_SPEED
		idle = false
	else:
		velocity.x = 0
	
	if Input.is_action_pressed('jump') and is_on_floor():
		velocity.y = -GRAVITY * JUMP_HEIGHT
		idle = false
	else:
		velocity.y += GRAVITY
	
	velocity = move_and_slide(velocity, Vector2.UP, false, 10)

	if idle and (is_on_floor() or is_on_wall()):
		animation_player.play('idle_' + last_direction)
	else:
		if velocity.x != 0:
			last_direction = ('right' if velocity.x > 0 else 'left')
		animation_player.play(('walk_' if (is_on_floor() or is_on_wall()) else 'jump_') + last_direction)
	
func new_game() -> void:
	position = default_position
	checkpoint_position = default_position


func check_colision(node: Node) -> void:
	if node.is_in_group('deadly'):
		velocity = Vector2(0, 0)
		Global.die()
		if Global.checkpoints:
			position = checkpoint_position
	if node.is_in_group('victory'):
		Global.win()
	if node.is_in_group('trigger'):
		node.trigger()
		if node.is_in_group('checkpoint'):
			checkpoint_position = node.position


func _on_Area2D_body_entered(body: Node) -> void:
	check_colision(body)


func _on_Area2D_area_entered(area: Area2D) -> void:
	check_colision(area)
		

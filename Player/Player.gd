extends KinematicBody2D

onready var animation_player := $AnimationPlayer

const WALK_SPEED := 300
const GRAVITY := 50
const JUMP_HEIGHT := 20
var velocity := Vector2(0, 0)

var last_direction := 'right'

onready var default_position := position
onready var checkpoint_position := default_position

signal victory


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


func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group('deadly'):
		if checkpoint_position == default_position:
			get_tree().call_group('new_game', 'new_game')
		else:
			position = checkpoint_position
	if body.is_in_group('victory'):
		emit_signal('victory')
	if body.is_in_group('trigger'):
		body.trigger()


func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.is_in_group('trigger'):
		area.trigger()
		if area.is_in_group('checkpoint'):
			checkpoint_position = area.position

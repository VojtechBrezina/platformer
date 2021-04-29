extends KinematicBody2D

onready var animation_player := $AnimationPlayer

const WALK_SPEED := 300
const GRAVITY := 50
const JUMP_HEIGHT := 20
var velocity := Vector2(0, 0)

var last_direction := false

var last_duck := false

onready var default_position := position
onready var checkpoint_position := default_position


func _ready() -> void:
	animation_player.play('idle')


func _physics_process(_delta: float) -> void:
	var idle := true
	var duck := false

	velocity.x = 0

	if Input.is_action_pressed('duck'):
		if not last_duck:
			$AnimationPlayer.play('duck')
		duck = true
	else:
		if Input.is_action_pressed('walk_left'):
			velocity.x = -WALK_SPEED
			idle = false
		elif Input.is_action_pressed('walk_right'):
			velocity.x = WALK_SPEED
			idle = false
		
	if Input.is_action_pressed('jump') and is_on_floor():
		velocity.y = -GRAVITY * JUMP_HEIGHT
		idle = false
	else:
		velocity.y += (GRAVITY * (3.0 if duck else 1.0))

	velocity = move_and_slide(velocity, Vector2.UP, false, 10)
	if not duck:
		if idle and (is_on_floor() or is_on_wall()):
			animation_player.play('idle')
		else:
			if velocity.x != 0:
				last_direction = velocity.x < 0
			animation_player.play('walk' if (is_on_floor() or is_on_wall()) else 'jump')
	layers = 1 if duck else 5
	$PlayerSprite.flip_h = last_direction
	last_duck = duck
	
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
		

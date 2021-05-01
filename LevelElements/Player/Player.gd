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
onready var checkpoint_environment := 'outside'

var light_energies := {
	'outside': 0.2,
	'cave': 0.3
}

var environment_colors := {
	'outside': Color8(201, 252, 255, 255),
	'cave': Color8(100, 100, 100, 255)
}

func _ready() -> void:
	animation_player.play('idle')
	var _tmp = get_viewport().connect('size_changed', self, '_resize')
	call_deferred('_resize')


func _resize() -> void:
	$Camera2D.zoom = Vector2(1, 1) * (2100 / $Camera2D.get_viewport().size.x)

func _physics_process(delta: float) -> void:
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
		
	if Input.is_action_pressed('jump') and (is_on_floor() or (Global.god_mode and Input.is_action_pressed('god_mode'))):
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

	get_tree().call_group('follow', 'follow', position, delta)

	layers = 1 if duck else 5
	$PlayerSprite.flip_h = last_direction
	last_duck = duck
	
func new_game() -> void:
	position = default_position
	checkpoint_position = default_position
	#$Camera2D.set_deferred('smoothing_enabled', true)


func check_colision(node: Node) -> void:
	if node.is_in_group('deadly') and not (Global.god_mode and Input.is_action_pressed('god_mode')):
		#$Camera2D.set_deferred('smoothing_enabled', false)
		velocity = Vector2(0, 0)
		get_tree().call_group('revivable', 'revive')
		Global.die()
		if Global.checkpoints or not Global.restart_on_death:
			position = checkpoint_position
			get_tree().call_group('environment', 'set_environment', checkpoint_environment)
	if node.is_in_group('victory'):
		Global.win()
	if node.is_in_group('trigger'):
		node.trigger()
		if node.is_in_group('checkpoint'):
			checkpoint_position = node.position
			checkpoint_environment = node.environment
			if node.level:
				Global.restart_on_death = false
	if node.is_in_group('cave_environment'):
		Global.set_environment('cave')
	if node.is_in_group('outside_environment'):
		Global.set_environment('outside')


func _on_Area2D_body_entered(body: Node) -> void:
	check_colision(body)


func _on_Area2D_area_entered(area: Area2D) -> void:
	check_colision(area)

func set_environment(e: String, fast: bool = false) -> void:
	if fast:
		$Light2D.energy = light_energies[e]
		$Background.modulate = environment_colors[e]
		return
	$Tween.interpolate_property($Light2D, 'energy', null, light_energies[e], 1)
	$Tween.interpolate_property($Background, 'modulate', null, environment_colors[e], 1)
	$Tween.start()
		
func _save() -> void:
	Global.save_state_data[str(get_path())] = {
		'pos_x': position.x,
		'pos_y': position.y,
		'vel_x': velocity.x,
		'vel_y': velocity.y,
		'cp_x': checkpoint_position.x,
		'cp_y': checkpoint_position.y,
		'cp_e': checkpoint_environment
	}

func _load(data: Dictionary) -> void:
	position = Vector2(float(data['pos_x']), float(data['pos_y']))
	velocity = Vector2(float(data['vel_x']), float(data['vel_y']))
	checkpoint_position = Vector2(float(data['cp_x']), float(data['cp_y']))
	checkpoint_environment = data['cp_e']

extends Sprite

const SPEED := 100

var following := false
onready var p_pos := position

onready var default_position := position
onready var default_region := region_rect
onready var default_scale := global_scale

var player: Node2D = null

var dead := false

var windows = {}

func _ready() -> void:
	$AnimationPlayer.stop()

func _process(delta: float) -> void:
	if not $Tween.is_active() and windows.size():
		if not $Tween.is_active():
			if global_scale == Vector2.ONE:
				dead = true
				$Tween.interpolate_property(self, 'modulate', null, Color(1,1,1,0), 1)
				$Area2D/CollisionShape2D.set_deferred('disabled', true)
				$LightOccluder2D.light_mask = 0
			else:
				$Tween.interpolate_property(self, 'scale', null, scale - Vector2.ONE, 1)
			$Tween.start()
	if player:
		follow(player.position, delta)


func follow(pos: Vector2, delta) -> void:
	if not following:
		return
	flip_h = position.x - p_pos.x >= 0
	p_pos = position
	var dist := (pos - position)
	position += dist.normalized() * (SPEED * delta)

func set_player(p: Node2D):
	player = p

func new_game() -> void:
	$Tween.remove_all()
	windows.clear()
	position = default_position
	modulate = Color(1,1,1,1)
	$Area2D/CollisionShape2D.set_deferred('disabled', false)
	$LightOccluder2D.light_mask = 1
	following = false
	$AnimationPlayer.stop()
	region_rect = default_region
	dead = false
	global_scale = default_scale

func wake_up() -> void:
	following = true
	$AnimationPlayer.play('fly')

func revive() -> void:
	new_game()

func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.is_in_group('holy'):
		windows[area] = true

func _on_Area2D_area_exited(area: Area2D) -> void:
	if area.is_in_group('holy'):
		windows.erase(area)


func _save() -> void:
	Global.save_state_data[str(get_path())] = {
		'pos_x': position.x,
		'pos_y': position.y,
		'following': following,
		'dead': dead,
		'scale': global_scale.x
	}

func _load(data: Dictionary) -> void:
	position = Vector2(float(data['pos_x']), float(data['pos_y']))
	following = data['following']
	dead = data['dead']
	global_scale = data['scale'] * Vector2.ONE
	if dead:
		modulate = Color(1,1,1,0)
		$Area2D/CollisionShape2D.set_deferred('disabled', true)
		$LightOccluder2D.light_mask = 0
		

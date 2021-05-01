extends Sprite

const SPEED := 100

var following := false
onready var p_pos := position

onready var default_position := position
onready var default_region := region_rect

var dead := false

func _ready() -> void:
	$AnimationPlayer.stop()

func follow(pos: Vector2, delta) -> void:
	if not following:
		return
	flip_h = position.x - p_pos.x >= 0
	p_pos = position
	var dist := (pos - position)
	position += dist.normalized() * (SPEED * delta)

func new_game() -> void:
	position = default_position
	modulate = Color(1,1,1,1)
	$Area2D/CollisionShape2D.set_deferred('disabled', false)
	$LightOccluder2D.light_mask = 1
	following = false
	$AnimationPlayer.stop()
	region_rect = default_region
	dead = false

func wake_up() -> void:
	following = true
	$AnimationPlayer.play('fly')

func revive() -> void:
	new_game()

func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.is_in_group('holy'):
		dead = true
		$Tween.interpolate_property(self, 'modulate', null, Color(1,1,1,0), 1)
		$Tween.start()
		$Area2D/CollisionShape2D.set_deferred('disabled', true)
		$LightOccluder2D.light_mask = 0

func _save() -> void:
	Global.save_state_data[str(get_path())] = {
		'pos_x': position.x,
		'pos_y': position.y,
		'following': following,
		'dead': dead
	}

func _load(data: Dictionary) -> void:
	position = Vector2(float(data['pos_x']), float(data['pos_y']))
	following = data['following']
	dead = data['dead']
	if dead:
		modulate = Color(1,1,1,0)
		$Area2D/CollisionShape2D.set_deferred('disabled', true)
		$LightOccluder2D.light_mask = 0
		

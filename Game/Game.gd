extends Node2D

var environment_colors := {
	'outside': Color8(240, 240, 240, 255),
	'cave': Color8(70, 70, 70, 255)
}

func _process(_delta: float) -> void:
	Global.emit_signal('progress', $ProgressPath.curve.get_closest_offset($Player.position) / $ProgressPath.curve.get_baked_length())

func set_environment(e: String, fast: bool = false) -> void:
	if fast:
		$CanvasModulate.color = environment_colors[e]
		return
	$CanvasModulate/Tween.interpolate_property($CanvasModulate, 'color', $CanvasModulate.color, environment_colors[e], 1)
	$CanvasModulate/Tween.set_active(true)

extends Area2D

var light_energies := {
	'outside': 0.2,
	'cave': 1
}

func _ready() -> void:
	$AnimationPlayer.play('burn')
	$Light2D.visible = true

func set_environment(e: String, fast: bool = false) -> void:
	if fast:
		$Light2D.energy = light_energies[e]
		return
	$Tween.interpolate_property($Light2D, 'energy', $Light2D.energy, light_energies[e], 1)
	$Tween.set_active(true)

extends Area2D

signal triggered
export(String, 'outside', 'cave') var environment := 'outside'
export(float) var zoom := 1.0

func trigger() -> void:
	emit_signal('triggered')

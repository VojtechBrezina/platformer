extends Area2D

signal triggered

func trigger() -> void:
	emit_signal('triggered')

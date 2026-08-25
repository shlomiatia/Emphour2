class_name Blink extends Node2D

@export var blink_duration := 0.5

var elapsed_time := 0.0

func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= blink_duration:
		elapsed_time = 0.0
		get_parent().visible = !get_parent().visible

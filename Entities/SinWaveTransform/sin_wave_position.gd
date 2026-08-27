class_name SineWavePosition extends Node

@export var magnitude := Vector2.ZERO
@export var speed := 1.0
@export var time_offset := 0.0

var original_position := Vector2.ZERO

func _ready() -> void:
	original_position = get_parent().position

func _process(_delta: float) -> void:
	var sine := sin(Time.get_ticks_msec() * 0.001 * speed + time_offset) * 0.5 + 0.5
	get_parent().position = original_position + sine * magnitude

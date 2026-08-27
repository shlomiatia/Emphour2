class_name SineWaveRotation extends Node

@export var magnitude_degrees := 0.0
@export var speed := 1.0
@export var time_offset := 0.0

var original_rotation_degrees := 0.0

func _ready() -> void:
	original_rotation_degrees = get_parent().rotation_degrees

func _process(_delta: float) -> void:
	var sine := sin(Time.get_ticks_msec() * 0.001 * speed + time_offset) * 0.5 + 0.5
	get_parent().rotation_degrees = original_rotation_degrees + sine * magnitude_degrees

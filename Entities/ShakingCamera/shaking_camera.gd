class_name ShakingCamera extends Camera2D

var strength := 0.0
@export_range(0.0, 1.0) var decay := 0.1
@export var intensity := 10.0

func _process(delta: float) -> void:
	if strength <= 0.0:
		position = Vector2.ZERO
		return
	position = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity)) * strength
	strength = lerpf(strength, 0.0, 1.0 - pow(1.0 - decay, delta * 60.0))

func shake(value := 1.0) -> void:
	strength = value

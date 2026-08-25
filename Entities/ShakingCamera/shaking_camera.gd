class_name ShakingCamera extends Camera2D

var strength := 0.0
var decay := 0.1
var intensity := 10.0

func _process(_delta: float) -> void:
	if strength <= 0.0:
		position = Vector2.ZERO
		return
	position = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity)) * strength
	strength = lerpf(strength, 0.0, decay)

func shake(value := 1.0) -> void:
	strength = value

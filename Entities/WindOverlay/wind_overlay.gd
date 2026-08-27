class_name WindOverlay extends Sprite2D

@export var patch_width := 240.0
@export var patch_height := 28.0

func _ready() -> void:
    var shader_material := material as ShaderMaterial
    shader_material.set_shader_parameter("patch_width_px", patch_width)
    shader_material.set_shader_parameter("patch_height_px", patch_height)

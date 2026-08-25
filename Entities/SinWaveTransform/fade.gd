class_name Fade extends ColorRect

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	show()

func fade_out() -> void:
	animation_player.play_backwards("Default")
	await animation_player.animation_finished

class_name Title extends Node2D

@onready var fade: Fade = $CanvasLayer/Fade
@onready var confirm_sound: AudioStreamPlayer = $ConfirmSound

var input_disabled := false

func _input(event: InputEvent) -> void:
    if !input_disabled && event.is_pressed():
        input_disabled = true
        confirm_sound.play()
        fade.fade_out()
        await confirm_sound.finished
        get_tree().change_scene_to_file("res://Scenes/Game/Game.tscn")

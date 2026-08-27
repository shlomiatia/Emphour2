class_name TutorialMessage extends CanvasLayer

const SOUNDS := [
	preload("res://Audio/confirm1.mp3"),
	preload("res://Audio/confirm2.mp3"),
	preload("res://Audio/confirm3.mp3")
]

@onready var text: Label = $Message/Text
@onready var confirm_sound: AudioStreamPlayer = $ConfirmSound

var messages := []
var current_index := 0

signal completed

func _ready() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if !visible || !event.is_pressed() || !is_advance_event(event):
		return
	get_viewport().set_input_as_handled()
	advance()

func is_advance_event(event: InputEvent) -> bool:
	return event is InputEventKey || event is InputEventMouseButton

func advance() -> void:
	confirm_sound.stream = SOUNDS.pick_random()
	confirm_sound.play()
	if current_index < messages.size() - 1:
		current_index += 1
		show_current_message()
		return
	hide()
	completed.emit()

func show_messages(value: Array) -> void:
	messages = value
	current_index = 0
	show()
	show_current_message()

func show_current_message() -> void:
	text.text = messages[current_index]

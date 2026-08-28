class_name TutorialMessage extends CanvasLayer

const SOUNDS := [
	preload("res://Audio/confirm1.mp3"),
	preload("res://Audio/confirm2.mp3"),
	preload("res://Audio/confirm3.mp3")
]
const BACKGROUND_ALPHA := 0.72

@onready var text: Label = $Message/Text
@onready var confirm_sound: AudioStreamPlayer = $ConfirmSound
@onready var message: ColorRect = $Message
@onready var spotlight: TutorialSpotlight = $Spotlight
@onready var input_blocker: Control = $InputBlocker

var messages := []
var current_index := 0
var can_advance := true

signal completed

func _ready() -> void:
	hide()

func _input(event: InputEvent) -> void:
	if !visible || !can_advance || !event.is_pressed() || !is_advance_event(event):
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
	hide_message()
	completed.emit()

func show_messages(value: Array) -> void:
	messages = value
	current_index = 0
	spotlight.clear()
	message.color.a = BACKGROUND_ALPHA
	can_advance = true
	input_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	show()
	show_current_message()

func show_message(value: String, highlight := Rect2()) -> void:
	messages = [value]
	current_index = 0
	spotlight.set_rect(highlight)
	message.color.a = 0.0 if highlight.size != Vector2.ZERO else BACKGROUND_ALPHA
	can_advance = true
	input_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	show()
	show_current_message()

func show_action(value: String, highlight := Rect2()) -> void:
	show_message(value, highlight)
	can_advance = false
	input_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE

func hide_message() -> void:
	spotlight.clear()
	hide()

func show_current_message() -> void:
	text.text = messages[current_index]

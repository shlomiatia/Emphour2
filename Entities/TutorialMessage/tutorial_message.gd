class_name TutorialMessage extends CanvasLayer

enum KingMode {OPEN, CLOSED, SHOCKED, HIDDEN}

const SOUNDS := [
	preload("res://Audio/confirm1.mp3"),
	preload("res://Audio/confirm2.mp3"),
	preload("res://Audio/confirm3.mp3")
]
const BACKGROUND_ALPHA := 0.72

@export var open_king: Texture2D
@export var closed_king: Texture2D
@export var shocked_king: Texture2D

@onready var text: Label = $Message/Text
@onready var king: TextureRect = $Message/King
@onready var confirm_sound: AudioStreamPlayer = $ConfirmSound
@onready var message: ColorRect = $Message
@onready var spotlight: TutorialSpotlight = $Spotlight
@onready var input_blocker: Control = $InputBlocker

var messages := []
var king_modes := []
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

func show_messages(value: Array, modes: Array = []) -> void:
	messages = value
	king_modes = modes
	current_index = 0
	spotlight.clear()
	message.color.a = BACKGROUND_ALPHA
	can_advance = true
	input_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	show()
	show_current_message()

func show_message(value: String, highlight := Rect2(), mode := KingMode.OPEN) -> void:
	messages = [value]
	king_modes = [mode]
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
	var mode: int = king_modes[current_index] if current_index < king_modes.size() else KingMode.OPEN
	king.visible = mode != KingMode.HIDDEN
	if king.visible:
		king.texture = king_texture(mode)

func king_texture(mode: int) -> Texture2D:
	if mode == KingMode.CLOSED:
		return closed_king
	if mode == KingMode.SHOCKED:
		return shocked_king
	return open_king

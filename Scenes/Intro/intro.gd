class_name Intro extends Node2D

const TEXTS := [
	"1,000 AD — a new millennium begins.",
	"King Robert the Pious is troubled...",
	"Rebels in Paris? Sacrebleu!",
	"General, defeat them — and all the others...",
	"Paint the map of Europe blue.",
	"For the Franks!"
]

const MOUTH_OPEN := [false, false, true, true, true, true]
const SOUNDS := [
	preload("res://Audio/confirm1.mp3"),
	preload("res://Audio/confirm2.mp3"),
	preload("res://Audio/confirm3.mp3")
]

@onready var text: Label = $CanvasLayer/Content/Text
@onready var king: TextureRect = $CanvasLayer/Content/King
@onready var fade: Fade = $CanvasLayer/Fade
@onready var confirm_sound: AudioStreamPlayer = $ConfirmSound

var current_index := 0
var input_disabled := false

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	show_current_text()

func _input(event: InputEvent) -> void:
	if !input_disabled && event.is_pressed():
		advance()

func advance() -> void:
	play_confirm_sound()
	if current_index < TEXTS.size() - 1:
		current_index += 1
		show_current_text()
	else:
		start_game()

func play_confirm_sound() -> void:
	confirm_sound.stream = SOUNDS.pick_random()
	confirm_sound.play()

func show_current_text() -> void:
	text.text = TEXTS[current_index]
	text.show()
	king.texture = load("res://Textures/KingOpenMouth.png") if MOUTH_OPEN[current_index] else load("res://Textures/King.png")

func start_game() -> void:
	input_disabled = true
	await fade.fade_out()
	get_tree().change_scene_to_file("res://Scenes/Game/Game.tscn")

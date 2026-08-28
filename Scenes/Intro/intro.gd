class_name Intro extends Node2D

const TEXTS := [
	"intro.opening.millennium",
	"intro.opening.king",
	"intro.opening.rebels",
	"intro.opening.general",
	"intro.opening.map",
	"intro.opening.franks"
]
const ACT_2_TEXTS := [
	"intro.act2.secured",
	"intro.act2.expand",
	"intro.act2.war",
	"intro.act2.ally",
	"intro.act2.carefully"
]
const ENDING_TEXTS := [
	"intro.ending.victorious",
	"intro.ending.shame",
	"intro.ending.life",
	"intro.ending.general",
	"intro.ending.never",
	"intro.ending.thanks"
]

const CLOSED_KING_TEXTS := [
	"intro.opening.millennium",
	"intro.opening.king",
	"intro.ending.thanks"
]
const SOUNDS := [
	preload("res://Audio/confirm1.mp3"),
	preload("res://Audio/confirm2.mp3"),
	preload("res://Audio/confirm3.mp3")
]

@onready var text: Label = $CanvasLayer/Content/Text
@onready var king: TextureRect = $CanvasLayer/Content/King
@onready var fade: Fade = $CanvasLayer/Fade
@onready var confirm_sound: AudioStreamPlayer = $ConfirmSound
@onready var audio: GameAudio = get_node("/root/Audio")

@export var open_king: Texture2D
@export var closed_king: Texture2D

var current_index := 0
var input_disabled := false
var texts := TEXTS

func _ready() -> void:
	audio.stop_music()
	texts = current_texts()
	await get_tree().create_timer(1.0).timeout
	show_current_text()

func _input(event: InputEvent) -> void:
	if !input_disabled && event.is_pressed():
		advance()

func advance() -> void:
	play_confirm_sound()
	if current_index < texts.size() - 1:
		current_index += 1
		show_current_text()
	else:
		start_game()

func play_confirm_sound() -> void:
	confirm_sound.stream = SOUNDS.pick_random()
	confirm_sound.play()

func show_current_text() -> void:
	text.text = tr(texts[current_index])
	text.show()
	king.texture = closed_king if CLOSED_KING_TEXTS.has(texts[current_index]) else open_king

func start_game() -> void:
	if CampaignState.intro == CampaignState.Intro.ENDING:
		restart_game()
		return
	input_disabled = true
	CampaignState.intro = CampaignState.Intro.OPENING
	await fade.fade_out()
	get_tree().change_scene_to_file("res://Scenes/Map/Map.tscn")

func restart_game() -> void:
	input_disabled = true
	CampaignState.reset()
	await fade.fade_out()
	get_tree().change_scene_to_file("res://Scenes/Intro/Intro.tscn")

func current_texts() -> Array:
	if CampaignState.intro == CampaignState.Intro.ACT_2:
		return ACT_2_TEXTS
	if CampaignState.intro == CampaignState.Intro.ENDING:
		return ENDING_TEXTS
	return TEXTS

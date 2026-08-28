class_name GameAudio extends Node

@onready var effects: AudioStreamPlayer = $Effects
@onready var music: AudioStreamPlayer = $Music

const MUSIC_TRACKS: Array[AudioStream] = [preload("res://Audio/music1.mp3"), preload("res://Audio/music2.mp3")]
const CARD_SOUNDS: Array[AudioStream] = [preload("res://Audio/playcard1.wav"), preload("res://Audio/playcard2.mp3"), preload("res://Audio/playcard3.mp3")]
const ATTACK_SOUNDS: Array[AudioStream] = [preload("res://Audio/attack1.ogg"), preload("res://Audio/attack2.ogg"), preload("res://Audio/attack3.mp3")]
const BLOCK_SOUNDS: Array[AudioStream] = [preload("res://Audio/block1.mp3"), preload("res://Audio/block2.mp3"), preload("res://Audio/block3.mp3")]
var music_index := 0

func _ready() -> void:
    music.finished.connect(replay_music)

func start_general_music() -> void:
    play_track(0)

func start_boss_music() -> void:
    play_track(1)

func stop_music() -> void:
    music.stop()
    music_index = 0

func replay_music() -> void:
    play_track(music_index)

func play_card() -> void:
    play_random(CARD_SOUNDS)

func play_attack() -> void:
    play_random(ATTACK_SOUNDS)

func play_block() -> void:
    play_random(BLOCK_SOUNDS)

func play_random(sounds: Array[AudioStream]) -> void:
    effects.stream = sounds.pick_random()
    effects.play()

func play_track(index: int) -> void:
    if music.playing && music_index == index:
        return
    music.stop()
    music_index = index
    music.stream = MUSIC_TRACKS[music_index]
    music.play()

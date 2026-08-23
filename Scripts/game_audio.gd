class_name GameAudio extends Node

@onready var effects: AudioStreamPlayer = $Effects
@onready var music: AudioStreamPlayer = $Music

var music_tracks: Array[AudioStream] = [preload("res://Audio/music1.mp3"), preload("res://Audio/music2.mp3"), preload("res://Audio/music3.mp3")]
var card_sounds: Array[AudioStream] = [preload("res://Audio/playcard1.wav"), preload("res://Audio/playcard2.mp3"), preload("res://Audio/playcard3.mp3")]
var attack_sounds: Array[AudioStream] = [preload("res://Audio/attack1.ogg"), preload("res://Audio/attack2.ogg"), preload("res://Audio/attack3.mp3")]
var block_sounds: Array[AudioStream] = [preload("res://Audio/block1.mp3"), preload("res://Audio/block2.mp3"), preload("res://Audio/block3.mp3")]
var music_index := 0

func _ready() -> void:
    music.finished.connect(play_next_track)

func start_music() -> void:
    if !music.playing:
        music.stream = music_tracks[music_index]
        music.play()

func play_card() -> void:
    play_random(card_sounds)

func play_attack() -> void:
    play_random(attack_sounds)

func play_block() -> void:
    play_random(block_sounds)

func play_random(sounds: Array[AudioStream]) -> void:
    effects.stream = sounds.pick_random()
    effects.play()

func play_next_track() -> void:
    music_index = (music_index + 1) % music_tracks.size()
    music.stream = music_tracks[music_index]
    music.play()

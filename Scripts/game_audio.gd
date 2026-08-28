class_name GameAudio extends Node

@onready var effects: AudioStreamPlayer = $Effects
@onready var music: AudioStreamPlayer = $Music
@onready var push: AudioStreamPlayer = $Push
@onready var win: AudioStreamPlayer = $Win
@onready var loss: AudioStreamPlayer = $Loss

const MUSIC_TRACKS: Array[AudioStream] = [preload("res://Audio/music1.mp3"), preload("res://Audio/music2.mp3"), preload("res://Audio/music3.mp3")]
const MUSIC_FADE_TIME := 0.6
const CARD_SOUNDS: Array[AudioStream] = [preload("res://Audio/playcard1.wav"), preload("res://Audio/playcard2.mp3"), preload("res://Audio/playcard3.mp3")]
const ATTACK_SOUNDS: Array[AudioStream] = [preload("res://Audio/attack1.ogg"), preload("res://Audio/attack2.ogg"), preload("res://Audio/attack3.mp3")]
const BLOCK_SOUNDS: Array[AudioStream] = [preload("res://Audio/block1.mp3"), preload("res://Audio/block2.mp3"), preload("res://Audio/block3.mp3")]
const PUSH_SOUNDS: Array[AudioStream] = [preload("res://Audio/whoosh1.wav"), preload("res://Audio/whoosh2.wav"), preload("res://Audio/whoosh3.wav")]
var music_index := -1
var music_fade: Tween

func _ready() -> void:
    music.finished.connect(replay_music)

func start_general_music() -> void:
    start_music()

func start_boss_music() -> void:
    start_music()

func stop_music() -> void:
    if is_fading_music():
        return
    if !music.playing:
        reset_music_volume()
        return
    music_fade = create_tween()
    music_fade.tween_property(music, "volume_db", -80.0, MUSIC_FADE_TIME)
    music_fade.tween_callback(stop_faded_music)

func stop_faded_music() -> void:
    music.stop()
    music_fade = null
    reset_music_volume()

func replay_music() -> void:
    play_track(next_track())

func start_music() -> void:
    if music.playing && !is_fading_music():
        return
    replay_music()

func next_track() -> int:
    return (music_index + 1) % MUSIC_TRACKS.size()

func play_card() -> void:
    play_random(CARD_SOUNDS)

func play_attack() -> void:
    play_random(ATTACK_SOUNDS)

func play_block() -> void:
    play_random(BLOCK_SOUNDS)

func play_push() -> void:
    push.stream = PUSH_SOUNDS.pick_random()
    push.play()

func play_result(player_won: bool) -> void:
    (win if player_won else loss).play()

func play_random(sounds: Array[AudioStream]) -> void:
    play_sound(sounds.pick_random())

func play_sound(sound: AudioStream) -> void:
    effects.stream = sound
    effects.play()

func play_track(index: int) -> void:
    if music.playing && music_index == index && !is_fading_music():
        return
    if is_fading_music():
        music_fade.kill()
        music_fade = null
    reset_music_volume()
    music.stop()
    music_index = index
    music.stream = MUSIC_TRACKS[music_index]
    music.play()

func reset_music_volume() -> void:
    music.volume_db = 0.0

func is_fading_music() -> bool:
    return music_fade != null && music_fade.is_valid() && music_fade.is_running()

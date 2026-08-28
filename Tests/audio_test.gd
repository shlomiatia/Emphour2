extends SceneTree

var audio: GameAudio

func _initialize() -> void:
    audio = root.get_node("Audio") as GameAudio
    await process_frame
    await verify_track_order()
    await verify_intro_map_boundary()
    quit()

func verify_track_order() -> void:
    audio.stop_music()
    audio.start_general_music()
    assert(audio.music.stream == GameAudio.MUSIC_TRACKS[0])
    audio.replay_music()
    assert(audio.music.stream == GameAudio.MUSIC_TRACKS[0])
    audio.start_boss_music()
    assert(audio.music.stream == GameAudio.MUSIC_TRACKS[1])
    audio.stop_music()
    audio.start_general_music()
    assert(audio.music.stream == GameAudio.MUSIC_TRACKS[0])

func verify_intro_map_boundary() -> void:
    audio.start_boss_music()
    var intro := await create_intro()
    assert(!audio.music.playing)
    var map := await create_map()
    assert(audio.music.playing)
    assert(audio.music.stream == GameAudio.MUSIC_TRACKS[0])
    intro.queue_free()
    map.queue_free()
    await process_frame
    audio.stop_music()

func create_intro() -> Intro:
    var intro := load("res://Scenes/Intro/Intro.tscn").instantiate() as Intro
    root.add_child(intro)
    await process_frame
    return intro

func create_map() -> CampaignMap:
    var map := load("res://Scenes/Map/Map.tscn").instantiate() as CampaignMap
    root.add_child(map)
    await process_frame
    return map

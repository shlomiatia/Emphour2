extends SceneTree

var audio: GameAudio

func _initialize() -> void:
    audio = root.get_node("Audio") as GameAudio
    await process_frame
    await verify_track_order()
    await verify_intro_map_boundary()
    await verify_selection_sounds()
    quit()

func verify_track_order() -> void:
    CampaignState.start_in_act_2 = false
    CampaignState.reset()
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
    CampaignState.start_in_act_2 = true
    CampaignState.reset()
    audio.start_general_music()
    assert(audio.music.stream == GameAudio.MUSIC_TRACKS[2])
    audio.stop_music()
    await create_timer(GameAudio.MUSIC_FADE_TIME + 0.1).timeout
    assert(!audio.music.playing)
    assert(audio.music.volume_db == 0.0)
    CampaignState.start_in_act_2 = false
    CampaignState.reset()

func verify_intro_map_boundary() -> void:
    audio.start_boss_music()
    var intro := await create_intro()
    await create_timer(GameAudio.MUSIC_FADE_TIME + 0.1).timeout
    assert(!audio.music.playing)
    var map := await create_map()
    assert(audio.music.playing)
    assert(audio.music.stream == GameAudio.MUSIC_TRACKS[0])
    intro.queue_free()
    map.queue_free()
    await process_frame
    audio.stop_music()

func verify_selection_sounds() -> void:
    var map := await create_map()
    var reward := load("res://Scenes/Reward/Reward.tscn").instantiate() as RewardScreen
    root.add_child(reward)
    await process_frame
    assert(map.confirm_sound.stream == load("res://Audio/click.wav"))
    assert(reward.confirm_sound.stream == load("res://Audio/buy.ogg"))
    assert(GameAudio.PUSH_SOUNDS.size() == 3)
    assert(BattleState.new().result_text(-1).contains("Press any key to restart level"))
    map.queue_free()
    reward.queue_free()

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

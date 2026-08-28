extends SceneTree

func _initialize() -> void:
	Engine.time_scale = 100.0
	await verify_king_textures()
	await verify_act_2_intro()
	await verify_ending_intro()
	quit()

func verify_king_textures() -> void:
	CampaignState.reset()
	var intro := await create_intro()
	assert(intro.king.texture == intro.closed_king)
	intro.current_index = 2
	intro.show_current_text()
	assert(intro.king.texture == intro.open_king)
	intro.queue_free()

func verify_act_2_intro() -> void:
	CampaignState.reset()
	CampaignState.intro = CampaignState.Intro.ACT_2
	var intro := await create_intro()
	assert(intro.texts == Intro.ACT_2_TEXTS)
	intro.queue_free()

func verify_ending_intro() -> void:
	CampaignState.reset()
	CampaignState.intro = CampaignState.Intro.ENDING
	var intro := await create_intro()
	assert(intro.texts == Intro.ENDING_TEXTS)
	intro.current_index = intro.texts.size() - 1
	intro.show_current_text()
	assert(intro.king.texture == intro.closed_king)
	intro.start_game()
	assert(intro.input_disabled)
	intro.queue_free()

func create_intro() -> Intro:
	var intro := load("res://Scenes/Intro/Intro.tscn").instantiate() as Intro
	root.add_child(intro)
	await process_frame
	return intro

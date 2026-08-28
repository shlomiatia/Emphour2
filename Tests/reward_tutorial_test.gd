extends SceneTree

func _initialize() -> void:
	await verify_tutorial()
	quit()

func verify_tutorial() -> void:
	CampaignState.reset()
	CampaignState.selected_city = CampaignState.act_1_city_id(1)
	var screen := await create_screen()
	verify_screen(screen)
	advance(screen)
	await verify_seen_tutorial(screen)
	CampaignState.start_in_act_2 = true
	CampaignState.reset()
	CampaignState.declare_war(CampaignState.Faction.ENGLISH)
	CampaignState.selected_city = CampaignState.act_2_city_id(1)
	var act_2_screen := await create_screen()
	assert(act_2_screen.tutorial.visible)
	assert((act_2_screen.tutorial.get_node("Message/Text") as Label).text == "General, we can press levies from English")
	act_2_screen.queue_free()

func verify_screen(screen: RewardScreen) -> void:
	assert(screen.tutorial.visible)
	assert(screen.tutorial.get_node("InputBlocker").mouse_filter == Control.MOUSE_FILTER_STOP)
	var deck_size := CampaignState.player_deck.size()
	click(screen.peasants.global_position)
	assert(screen.tutorial.current_index == 1 && !screen.input_disabled)
	assert(CampaignState.player_deck.size() == deck_size)

func verify_seen_tutorial(screen: RewardScreen) -> void:
	screen.queue_free()
	await process_frame
	var later_screen := await create_screen()
	assert(!later_screen.tutorial.visible)
	later_screen.queue_free()

func create_screen() -> RewardScreen:
	var screen := load("res://Scenes/Reward/Reward.tscn").instantiate() as RewardScreen
	root.add_child(screen)
	await process_frame
	return screen

func click(point: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	root.get_viewport().push_input(event, true)

func advance(screen: RewardScreen) -> void:
	for _index in 3:
		click(Vector2.ZERO)
	press_key()
	assert(!screen.tutorial.visible)

func press_key() -> void:
	var event := InputEventKey.new()
	event.keycode = KEY_SPACE
	event.pressed = true
	root.get_viewport().push_input(event, true)

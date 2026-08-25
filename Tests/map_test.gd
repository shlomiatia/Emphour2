extends SceneTree

var map: CampaignMap

func _initialize() -> void:
	run_test()

func run_test() -> void:
	await open_map()
	verify_campaign()
	verify_tooltips()
	await verify_hover()
	await verify_battle_transition()
	current_scene.queue_free()
	for _frame in 5:
		await process_frame
	await process_frame
	quit()

func open_map() -> void:
	Engine.time_scale = 20.0
	var intro: Intro = load("res://Scenes/Intro/Intro.tscn").instantiate()
	root.add_child(intro)
	current_scene = intro
	for _frame in 5:
		await process_frame
	intro.start_game()
	for _frame in 30:
		await process_frame
	map = current_scene as CampaignMap
	assert(map)

func verify_campaign() -> void:
	var cities := map.get_node("MapElements/Cities")
	assert(cities.get_child_count() == 12)
	assert(cities.get_node("Paris").modulate == Color("#0099db"))
	assert(cities.get_node("Rouen").modulate == Color("#f5eee2"))
	assert(!cities.get_node("Paris").attackable)
	assert(cities.get_node("Rouen").attackable)
	assert(cities.get_node("Reims").attackable)
	assert(!cities.get_node("Amiens").attackable)
	assert(!cities.get_node("Verdun").attackable)
	assert(map.england_status.text == "Neutral")
	assert(map.peasants_status.text == "Neutral")

func verify_tooltips() -> void:
	var cities := map.get_node("MapElements/Cities")
	map.update_tooltip(cities.get_node("Rouen"))
	assert(map.tooltip_title.text == "Attack Rouen")
	assert(map.england_current.text == "Neutral")
	assert(map.england_target.text == "Trade Embargo")
	assert(map.empire_target.text == "Trade Pact")
	map.update_tooltip(cities.get_node("Reims"))
	assert(map.england_target.text == "Trade Pact")
	assert(map.empire_target.text == "Trade Embargo")

func verify_hover() -> void:
	var rouen: CampaignCity = map.get_node("MapElements/Cities/Rouen")
	rouen.hovered.emit(rouen)
	await process_frame
	assert(map.tooltip.visible)
	assert(map.tooltip_title.text == "Attack Rouen")

func verify_battle_transition() -> void:
	map._on_city_clicked(map.get_node("MapElements/Cities/Amiens"))
	await process_frame
	assert(!map.input_disabled)
	map._on_city_clicked(map.get_node("MapElements/Cities/Rouen"))
	for _frame in 30:
		await process_frame
	assert(CampaignState.selected_city == "Rouen")
	assert(CampaignState.selected_front == CampaignState.Faction.ENGLAND)
	assert(current_scene is CardGame)

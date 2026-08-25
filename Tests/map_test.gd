extends SceneTree

var map: CampaignMap

func _initialize() -> void:
	run_test()

func run_test() -> void:
	await open_map()
	verify_campaign()
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
	assert(cities.get_child_count() == 6)
	assert(!map.get_node_or_null("CanvasLayer/ForeignRelations"))
	assert(!map.get_node_or_null("CanvasLayer/Tooltip"))
	for city in cities.get_children():
		assert(city.get_node("Name").text == city.city_name)
	assert(cities.get_node("Paris").modulate == Color("#f5eee2"))
	assert(cities.get_node("Paris").attackable)
	assert(!cities.get_node("Rouen").attackable)
	assert(!cities.get_node("Amiens").attackable)
	assert(map.peasants_status.text == "Neutral")

func verify_battle_transition() -> void:
	map._on_city_clicked(map.get_node("MapElements/Cities/Rouen"))
	await process_frame
	assert(!map.input_disabled)
	map._on_city_clicked(map.get_node("MapElements/Cities/Paris"))
	for _frame in 30:
		await process_frame
	assert(CampaignState.selected_city == "Paris")
	assert(current_scene is CardBattle)

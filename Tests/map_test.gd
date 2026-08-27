extends SceneTree

var map: CampaignMap

func _initialize() -> void:
	run_test()

func run_test() -> void:
	verify_act_2_shortcut()
	await open_map()
	verify_campaign()
	await verify_battle_transition()
	await open_foreign_map()
	verify_foreign_campaign()
	await verify_card_factions()
	quit()

func verify_act_2_shortcut() -> void:
	CampaignState.start_in_act_2 = true
	CampaignState.reset()
	assert(CampaignState.foreign_relations_active())
	assert(CampaignState.player_deck == CampaignState.ACT_2_STARTING_DECK)
	assert(CampaignState.city_owner.values().all(func(owner: int) -> bool: return owner == CampaignState.Faction.FRANKS))
	CampaignState.start_in_act_2 = false
	CampaignState.reset()

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
	var road := map.get_node("MapElements/Roads/Road") as Line2D
	assert(cities.get_child_count() == 18)
	assert(road.get_point_count() == 6)
	assert(!map.get_node("MapElements/Roads/EnglandRoad").visible)
	assert(!map.get_node("MapElements/Roads/HreRoad").visible)
	assert(!map.tooltip.visible)
	assert(map.title.text == "KINGDOM LOYALTY")
	assert(!cities.get_node("London").visible)
	assert(cities.get_node("City1").attackable)
	assert(!cities.get_node("City2").attackable)
	assert(map.peasants_status.text == "Neutral")

func verify_battle_transition() -> void:
	map._on_city_clicked(map.get_node("MapElements/Cities/City3"))
	await process_frame
	assert(!map.input_disabled)
	map._on_city_clicked(map.get_node("MapElements/Cities/City1"))
	for _frame in 30:
		await process_frame
	assert(CampaignState.selected_city == "City 1")
	assert(current_scene is CardBattle)

func open_foreign_map() -> void:
	current_scene.queue_free()
	CampaignState.reset()
	for city in CampaignState.STARTING_OWNERS:
		CampaignState.selected_city = city
		CampaignState.capture_selected_city()
	CampaignState.selected_city = "City 1"
	CampaignState.capture_selected_city()
	map = load("res://Scenes/Map/Map.tscn").instantiate()
	root.add_child(map)
	current_scene = map
	await process_frame

func verify_foreign_campaign() -> void:
	var cities := map.get_node("MapElements/Cities")
	assert(CampaignState.foreign_relations_active())
	assert(map.title.text == "FOREIGN RELATIONS")
	assert(map.first_name.text == "English")
	assert(map.second_name.text == "Holy Roman Empire")
	assert(cities.get_node("London").attackable)
	assert(cities.get_node("Aachen").attackable)
	assert(map.get_node("MapElements/Roads/EnglandRoad").visible)
	assert(map.get_node("MapElements/Roads/HreRoad").visible)
	assert(!cities.get_node("York").attackable)
	assert(cities.get_node("London/Marker").modulate == Color("#e43b44"))
	assert(cities.get_node("Aachen/Marker").modulate == Color("#feae34"))
	map._on_city_hovered(cities.get_node("London"))
	assert(map.tooltip.visible)
	assert(map.tooltip_title.text == "Declare war on English")
	assert(map.tooltip_changes[0].get_node("Change/Target").text == "Treacherous")
	assert(map.tooltip_changes[1].get_node("Change/Target").text == "Devoted")
	map._on_city_clicked(cities.get_node("London"))
	assert(CampaignState.foreign_loyalty[CampaignState.Faction.ENGLISH] == CampaignState.Relation.WAR)
	assert(CampaignState.foreign_loyalty[CampaignState.Faction.HRE] == CampaignState.Relation.MILITARY_ALLIANCE)
	assert(!cities.get_node("London").attackable)
	assert(current_scene is CampaignMap)

func verify_card_factions() -> void:
	for faction in [CampaignState.Faction.FRANKS, CampaignState.Faction.REBELS, CampaignState.Faction.ENGLISH, CampaignState.Faction.HRE]:
		var card := CardFactory.create("Militia", GameRules.Side.PLAYER, faction)
		root.add_child(card)
		await process_frame
		var material := card.art.material as ShaderMaterial
		assert(material.get_shader_parameter("is_colored") == (faction != CampaignState.Faction.REBELS))
		card.queue_free()

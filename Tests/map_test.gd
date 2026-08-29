extends SceneTree

var map: CampaignMap

func _initialize() -> void:
    run_test()

func run_test() -> void:
    await verify_initial_header()
    CampaignState.start_in_act_2 = true
    CampaignState.reset()
    await verify_tooltip_order()
    verify_declaration()
    await verify_route()
    await verify_boss()
    await verify_act_1_boss_tutorial()
    await verify_act_1_boss_tie()
    quit()

func verify_initial_header() -> void:
    CampaignState.start_in_act_2 = false
    CampaignState.reset()
    await open_map()
    assert(!map.kingdom_loyalty.visible)
    map.queue_free()

func open_map() -> void:
    map = load("res://Scenes/Map/Map.tscn").instantiate()
    root.add_child(map)
    current_scene = map
    await process_frame

func find_city(faction: int, index: int) -> CampaignCity:
    for child in map.get_node("MapElements/Cities").get_children():
        var city := child as CampaignCity
        if city.faction == faction && city.route_index == index:
            return city
    return null

func verify_declaration() -> void:
    CampaignState.declare_war(CampaignState.Faction.ENGLISH)
    assert(CampaignState.selected_city == CampaignState.act_2_city_id(1))
    assert(CampaignState.foreign_loyalty[CampaignState.Faction.ENGLISH] == CampaignState.Relation.WAR)
    assert(CampaignState.foreign_loyalty[CampaignState.Faction.HRE] == CampaignState.Relation.MILITARY_ALLIANCE)

func verify_tooltip_order() -> void:
    await open_map()
    assert(tag_text(map.first_status) == "Neutral (0)")
    assert(tag_text(map.second_status) == "Neutral (0)")
    map._on_city_hovered(find_city(CampaignState.Faction.HRE, 1))
    var english := map.tooltip_changes[0] as LoyaltyChange
    var hre := map.tooltip_changes[1] as LoyaltyChange
    assert((english.get_node("Group/Name") as Label).text == "English")
    assert((hre.get_node("Group/Name") as Label).text == "HRE")
    assert(tag_text(english.get_node("Comparison/Target")) == "Devoted (5)")
    assert(tag_text(hre.get_node("Comparison/Target")) == "Treacherous (-5)")
    map.queue_free()

func tag_text(tag: LoyaltyTag) -> String:
    return tag.text

func verify_route() -> void:
    CampaignState.capture_selected_city()
    await open_map()
    assert(find_city(CampaignState.Faction.ENGLISH, 2).attackable)
    assert(!find_city(CampaignState.Faction.HRE, 1).attackable)

func verify_boss() -> void:
    CampaignState.act_2_progress = 5
    await open_map()
    var host := map.get_node("MapElements/Cities/Act1City1") as CampaignCity
    assert(host.attackable)
    assert(CampaignState.map_city_id(host.city_id) == "Act 2 Boss")
    assert(host.marker.modulate == CampaignState.faction_color(CampaignState.Faction.HRE))
    assert(find_city(CampaignState.Faction.ENGLISH, 1).marker.modulate == CampaignState.faction_color(CampaignState.Faction.FRANKS))
    assert(find_city(CampaignState.Faction.HRE, 1).marker.modulate == CampaignState.faction_color(CampaignState.Faction.HRE))
    assert(CampaignState.foreign_loyalty[CampaignState.Faction.HRE] == CampaignState.Relation.WAR)
    assert(CampaignState.foreign_loyalty[CampaignState.Faction.ENGLISH] == CampaignState.Relation.WAR)
    assert(map.tutorial.visible)
    assert((map.tutorial.get_node("Message/Text") as Label).text == "...")
    assert((map.tutorial.get_node("Message/King") as TextureRect).texture == map.tutorial.shocked_king)
    map.tutorial.advance()
    assert((map.tutorial.get_node("Message/Text") as Label).text == "General, the Holy Roman Empire has double-crossed us!")
    assert((map.tutorial.get_node("Message/King") as TextureRect).texture == map.tutorial.open_king)

func verify_act_1_boss_tutorial() -> void:
    CampaignState.start_in_act_2 = false
    CampaignState.reset()
    CampaignState.loyalty = {"Peasants": -1, "Nobility": -3}
    for index in 5:
        CampaignState.selected_city = CampaignState.act_1_city_id(index + 1)
        CampaignState.capture_selected_city()
    await open_map()
    var host := map.get_node("MapElements/Cities/Act1City1") as CampaignCity
    assert(host.marker.modulate == CampaignState.faction_color(CampaignState.Faction.FRANKS))
    assert(host.animation_player.current_animation == "Pulse")
    assert(map.tutorial.visible)
    assert((map.tutorial.get_node("Message/Text") as Label).text == "...")
    map.tutorial.advance()
    assert((map.tutorial.get_node("Message/Text") as Label).text == "General, the Nobility are trying to take Paris!")
    assert((map.tutorial.get_node("Message/King") as TextureRect).texture == map.tutorial.open_king)
    assert(CampaignState.loyalty["Nobility"] == CampaignState.Relation.WAR)
    assert(CampaignState.loyalty["Peasants"] == -1)

func verify_act_1_boss_tie() -> void:
    CampaignState.start_in_act_2 = false
    CampaignState.reset()
    for index in 5:
        CampaignState.selected_city = CampaignState.act_1_city_id(index + 1)
        CampaignState.capture_selected_city()
    await open_map()
    assert(CampaignState.loyalty["Peasants"] == CampaignState.Relation.NEUTRAL)
    assert(CampaignState.loyalty["Nobility"] == CampaignState.Relation.WAR)

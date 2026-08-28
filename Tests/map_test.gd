extends SceneTree

var map: CampaignMap

func _initialize() -> void:
    run_test()

func run_test() -> void:
    CampaignState.start_in_act_2 = true
    CampaignState.reset()
    verify_declaration()
    await verify_route()
    await verify_boss()
    await verify_act_1_boss_tutorial()
    quit()

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
    assert((map.tutorial.get_node("Message/Text") as Label).text == "General, the HRE has double crossed us!")

func verify_act_1_boss_tutorial() -> void:
    CampaignState.start_in_act_2 = false
    CampaignState.reset()
    for index in 5:
        CampaignState.selected_city = CampaignState.act_1_city_id(index + 1)
        CampaignState.capture_selected_city()
    await open_map()
    assert(map.tutorial.visible)
    assert((map.tutorial.get_node("Message/Text") as Label).text == "General, the Nobility are trying to take Paris!")

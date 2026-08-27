extends SceneTree

var map: CampaignMap

func _initialize() -> void:
    run_test()

func run_test() -> void:
    CampaignState.start_in_act_2 = true
    CampaignState.reset()
    await open_map()
    verify_declaration()
    verify_route()
    verify_boss()
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
    var city := find_city(CampaignState.Faction.ENGLISH, 1)
    assert(city.attackable)
    map._on_city_clicked(city)
    await process_frame
    assert(CampaignState.selected_city == CampaignState.act_2_city_id(1))
    assert(CampaignState.foreign_loyalty[CampaignState.Faction.ENGLISH] == CampaignState.Relation.WAR)
    assert(CampaignState.foreign_loyalty[CampaignState.Faction.HRE] == CampaignState.Relation.MILITARY_ALLIANCE)

func verify_route() -> void:
    CampaignState.capture_selected_city()
    await open_map()
    assert(find_city(CampaignState.Faction.ENGLISH, 2).attackable)
    assert(!find_city(CampaignState.Faction.HRE, 1).attackable)

func verify_boss() -> void:
    CampaignState.act_2_progress = 6
    await open_map()
    var host := map.get_node("MapElements/Cities/Act1City1") as CampaignCity
    assert(host.attackable)
    assert(CampaignState.map_city_id(host.city_id) == "Act 2 Boss")
    assert(host.marker.modulate == CampaignState.faction_color(CampaignState.Faction.HRE))

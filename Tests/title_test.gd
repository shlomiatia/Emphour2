extends SceneTree

func _initialize() -> void:
    run_test()

func run_test() -> void:
    CampaignState.reset()
    var title := load("res://Scenes/Title/Title.tscn").instantiate() as Title
    root.add_child(title)
    await process_frame
    verify_cities(title)
    quit()

func verify_cities(title: Title) -> void:
    var cities := title.get_node("Cities").get_children()
    assert(cities.size() == 15)
    for city in cities:
        assert(city.visible && !city.attackable && !city.input_pickable && !city.name_label.text.is_empty())
        assert(city.marker.modulate == CampaignState.faction_color(city.faction))

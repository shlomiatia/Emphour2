extends SceneTree

func _initialize() -> void:
    verify_rewards()
    verify_act_1_boss()
    quit()

func verify_rewards() -> void:
    CampaignState.reset()
    var deck := CampaignState.create_frank_deck(["Archer", "Horse Archer"])
    var offer := RewardRules.create_offer("Peasants", 5, deck)
    var count := deck.size()
    RewardRules.apply_offer(offer, deck)
    assert(deck.size() == count)
    assert(deck.all(func(entry: CampaignCard) -> bool: return entry.faction == CampaignState.Faction.FRANKS))

func verify_act_1_boss() -> void:
    CampaignState.reset()
    for index in 6:
        CampaignState.selected_city = CampaignState.act_1_city_id(index + 1)
        CampaignState.capture_selected_city()
        if index == 4:
            assert(CampaignState.map_city_id(CampaignState.act_1_city_id(1)) == CampaignState.act_1_city_id(1))
    assert(CampaignState.map_city_id(CampaignState.act_1_city_id(1)) == "Act 1 Boss")
    CampaignState.selected_city = "Act 1 Boss"
    CampaignState.capture_selected_city()
    assert(CampaignState.is_act_2())

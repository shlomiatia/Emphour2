extends SceneTree

func _initialize() -> void:
    verify_rewards()
    verify_act_2_levels()
    verify_act_2_factions()
    verify_act_2_upgrade()
    verify_act_2_priority()
    verify_act_2_paths()
    await verify_act_2_screen()
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
    CampaignState.start_in_act_2 = false
    CampaignState.reset()
    for index in 5:
        CampaignState.selected_city = CampaignState.act_1_city_id(index + 1)
        CampaignState.capture_selected_city()
        if index == 4:
            assert(CampaignState.map_city_id(CampaignState.act_1_city_id(1)) == CampaignState.act_1_city_id(1))
    assert(CampaignState.map_city_id(CampaignState.act_1_city_id(1)) == "Act 1 Boss")
    CampaignState.selected_city = "Act 1 Boss"
    CampaignState.capture_selected_city()
    assert(CampaignState.is_act_2())

func verify_act_2_levels() -> void:
    setup_act_2()
    for index in 5:
        CampaignState.selected_city = CampaignState.act_2_city_id(index + 1)
        assert(CampaignState.act_2_reward_level(CampaignState.Faction.ENGLISH) == [2, 3, 4, 5, 6][index])
        assert(CampaignState.act_2_reward_level(CampaignState.Faction.HRE) == [1, 2, 3, 4, 5][index])

func verify_act_2_factions() -> void:
    var deck: Array[CampaignCard] = [CampaignCard.new("Militia", CampaignState.Faction.FRANKS)]
    var offer := Act2RewardRules.create_offer(CampaignState.Faction.ENGLISH, 1, deck)
    RewardRules.apply_offer(offer, deck)
    assert(deck.back().faction == CampaignState.Faction.ENGLISH)

func verify_act_2_upgrade() -> void:
    var deck := act_2_upgrade_deck()
    var offer := Act2RewardRules.create_offer(CampaignState.Faction.ENGLISH, 2, deck)
    RewardRules.apply_offer(offer, deck)
    assert(!deck.has(offer["source"]))
    assert(deck.back().faction == CampaignState.Faction.ENGLISH)

func verify_act_2_priority() -> void:
    var deck := act_2_upgrade_deck()
    assert(Act2RewardRules.create_offer(CampaignState.Faction.ENGLISH, 2, deck)["source"].faction == CampaignState.Faction.FRANKS)
    deck.erase(deck.filter(func(card: CampaignCard) -> bool: return card.faction == CampaignState.Faction.FRANKS)[0])
    assert(Act2RewardRules.create_offer(CampaignState.Faction.ENGLISH, 2, deck)["source"].faction == CampaignState.Faction.ENGLISH)
    deck.erase(deck.filter(func(card: CampaignCard) -> bool: return card.faction == CampaignState.Faction.ENGLISH)[0])
    assert(Act2RewardRules.create_offer(CampaignState.Faction.ENGLISH, 2, deck)["source"].faction == CampaignState.Faction.HRE)

func verify_act_2_paths() -> void:
    assert(Act2RewardRules.rewards(5).size() == 4)
    assert(Act2RewardRules.rewards(5).count({"new": "Crossbowman"}) == 1)

func verify_act_2_screen() -> void:
    setup_act_2()
    var screen := load("res://Scenes/Reward/Reward.tscn").instantiate() as RewardScreen
    root.add_child(screen)
    await process_frame
    assert(!screen.peasants.loyalty.visible && !screen.nobility.loyalty.visible)
    assert(screen.peasants.title.title == "English" && screen.nobility.title.title == "HRE")
    assert(screen.peasants.faction_shield.visible && screen.nobility.faction_shield.visible)
    screen.queue_free()

func setup_act_2() -> void:
    CampaignState.start_in_act_2 = true
    CampaignState.reset()
    CampaignState.declare_war(CampaignState.Faction.ENGLISH)

func act_2_upgrade_deck() -> Array[CampaignCard]:
    return [CampaignCard.new("Archer", CampaignState.Faction.FRANKS), CampaignCard.new("Archer", CampaignState.Faction.ENGLISH), CampaignCard.new("Archer", CampaignState.Faction.HRE)]

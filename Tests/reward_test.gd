extends SceneTree

func _initialize() -> void:
    verify_rewards()
    verify_reward_levels()
    verify_act_2_levels()
    verify_act_2_factions()
    verify_act_2_upgrade()
    verify_act_2_priority()
    verify_act_2_paths()
    verify_exclusions()
    verify_boss_rewards()
    await verify_act_2_screen()
    verify_act_1_boss()
    quit()

func verify_rewards() -> void:
    CampaignState.reset()
    CampaignState.loyalty = {"Peasants": 1, "Nobility": -1}
    var deck := CampaignState.create_frank_deck(["Archer", "Horse Archer"])
    var offer := RewardRules.create_offer("Peasants", 2, deck)
    var count := deck.size()
    RewardRules.apply_offer(offer, deck)
    assert(deck.size() == count + 1)
    assert(deck.all(func(entry: CampaignCard) -> bool: return entry.faction == CampaignState.Faction.FRANKS))
    var option := RewardOption.new()
    option.offer = {"old": "Crossbowman", "new": "Heavy Cavalry"}
    assert(option.offer_text() == "Upgrade crossbow from deck to heavy cav.")

func verify_reward_levels() -> void:
    CampaignState.reset()
    assert(RewardRules.reward_level("Peasants", 1) == 1 && RewardRules.reward_level("Nobility", 1) == 1)
    var deck := CampaignState.create_frank_deck(["Archer", "Light Cavalry"])
    assert(RewardRules.create_offer("Peasants", 1, deck)["old"].is_empty())
    assert(RewardRules.create_offer("Nobility", 1, deck)["old"].is_empty())
    assert(!RewardRules.reward_rule("Act1", "Peasants", 1)["upgrade"])
    assert(!RewardRules.reward_rule("Act1", "Nobility", 1)["upgrade"])
    CampaignState.loyalty = {"Peasants": 1, "Nobility": -1}
    assert(RewardRules.reward_level("Peasants", 1) == 1 && RewardRules.reward_level("Nobility", 1) == 1)
    assert(RewardRules.reward_level("Peasants", 3) == 3 && RewardRules.reward_level("Nobility", 3) == 2)
    CampaignState.loyalty = {"Peasants": 0, "Nobility": 0}
    assert(RewardRules.reward_level("Peasants", 4) == 4 && RewardRules.reward_level("Nobility", 4) == 4)

func verify_act_1_boss() -> void:
    CampaignState.start_in_act_2 = false
    CampaignState.reset()
    for index in 5:
        CampaignState.selected_city = CampaignState.act_1_city_id(index + 1)
        CampaignState.capture_selected_city()
        if index == 4:
            assert(CampaignState.map_city_id(CampaignState.act_1_city_id(1)) == "Act 1 Boss")
    assert(CampaignState.map_city_id(CampaignState.act_1_city_id(1)) == "Act 1 Boss")
    CampaignState.selected_city = "Act 1 Boss"
    CampaignState.capture_selected_city()
    assert(CampaignState.is_act_2())

func verify_act_2_levels() -> void:
    setup_act_2()
    for index in 5:
        CampaignState.selected_city = CampaignState.act_2_city_id(index + 1)
        assert(!Act2RewardRules.rewards("War", index + 1).is_empty())
        assert(!Act2RewardRules.rewards("Ally", index + 1).is_empty())

func verify_act_2_factions() -> void:
    var deck: Array[CampaignCard] = [CampaignCard.new("Militia", CampaignState.Faction.FRANKS)]
    var offer := Act2RewardRules.create_offer(CampaignState.Faction.ENGLISH, 1, deck)
    RewardRules.apply_offer(offer, deck)
    assert(deck.back().faction == CampaignState.Faction.ENGLISH)

func verify_act_2_upgrade() -> void:
    var deck := act_2_upgrade_deck()
    var offer := Act2RewardRules.create_offer(CampaignState.Faction.ENGLISH, 1, deck)
    RewardRules.apply_offer(offer, deck)
    assert(!deck.has(offer["source"]))
    assert(deck.back().faction == CampaignState.Faction.ENGLISH)

func verify_act_2_priority() -> void:
    var deck := act_2_upgrade_deck()
    var reward := RewardRules.parse_rule("upgrade:1:2:exclude:Crossbowman")
    assert(Act2RewardRules.pick_source(CampaignState.Faction.ENGLISH, reward, deck).faction == CampaignState.Faction.FRANKS)
    deck.erase(deck.filter(func(card: CampaignCard) -> bool: return card.faction == CampaignState.Faction.FRANKS)[0])
    assert(Act2RewardRules.pick_source(CampaignState.Faction.ENGLISH, reward, deck).faction == CampaignState.Faction.ENGLISH)
    deck.erase(deck.filter(func(card: CampaignCard) -> bool: return card.faction == CampaignState.Faction.ENGLISH)[0])
    assert(Act2RewardRules.pick_source(CampaignState.Faction.ENGLISH, reward, deck).faction == CampaignState.Faction.HRE)

func verify_act_2_paths() -> void:
    assert(Act2RewardRules.rewards("War", 5).size() == 2)
    assert(Act2RewardRules.rewards("War", 2).has("new:Crossbowman"))

func verify_boss_rewards() -> void:
    CampaignState.start_in_act_2 = false
    CampaignState.reset()
    CampaignState.selected_city = "Act 1 Boss"
    var deck := CampaignState.create_frank_deck(["Archer"])
    var add := RewardRules.create_boss_offer("Peasants", 1, deck)
    var upgrade := RewardRules.create_boss_offer("Peasants", 2, deck)
    assert(add["new"] == "Crossbowman")
    assert(upgrade["old"] == "Archer" && upgrade["new"] == "Crossbowman")

func verify_exclusions() -> void:
    CampaignState.selected_city = CampaignState.act_1_city_id(3)
    var reward := RewardRules.parse_rule("new:2:exclude:Crossbowman")
    var cards := RewardRules.target_cards("Peasants", reward, "", CampaignBalance.reward_exclusions(CampaignState.selected_city))
    assert(!cards.has("Crossbowman"))
    var offer := RewardRules.create_offer("Nobility", 2, CampaignState.player_deck)
    assert(!offer["new"].is_empty())

func verify_act_2_screen() -> void:
    setup_act_2()
    var screen := load("res://Scenes/Reward/Reward.tscn").instantiate() as RewardScreen
    root.add_child(screen)
    await process_frame
    assert(screen.peasants.loyalty.visible && screen.nobility.loyalty.visible)
    assert(screen.peasants.title.title == "English" && screen.nobility.title.title == "HRE")
    assert(screen.peasants.faction_shield.visible && screen.nobility.faction_shield.visible)
    assert(!screen.peasants.description.text.contains("English"))
    assert(!screen.nobility.description.text.contains("HRE"))
    verify_foreign_loyalty(screen.peasants)
    verify_foreign_loyalty(screen.nobility)
    screen.queue_free()

func verify_foreign_loyalty(option: RewardOption) -> void:
    var english := option.loyalty.get_child(0)
    var hre := option.loyalty.get_child(1)
    assert((english.get_node("Group/Name") as Label).text == "English")
    assert((hre.get_node("Group/Name") as Label).text == "HRE")
    assert(!(english.get_node("Change/Arrow") as Control).visible)
    assert(!(hre.get_node("Change/Target") as Control).visible)
    assert((english.get_node("Change/Current") as Label).text == "Treacherous")
    assert((hre.get_node("Change/Current") as Label).text == "Devoted")

func setup_act_2() -> void:
    CampaignState.start_in_act_2 = true
    CampaignState.reset()
    CampaignState.declare_war(CampaignState.Faction.ENGLISH)

func act_2_upgrade_deck() -> Array[CampaignCard]:
    return [CampaignCard.new("Archer", CampaignState.Faction.FRANKS), CampaignCard.new("Archer", CampaignState.Faction.ENGLISH), CampaignCard.new("Archer", CampaignState.Faction.HRE)]

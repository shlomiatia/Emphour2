extends SceneTree

func _initialize() -> void:
    verify_decks()
    verify_factions()
    quit()

func verify_decks() -> void:
    CampaignState.start_in_act_2 = false
    CampaignState.reset()
    verify_deck(CampaignState.act_1_city_id(1))
    verify_deck(CampaignState.act_1_city_id(3))
    verify_act_1_boss_decks()
    verify_act_2_keeps_deck()
    CampaignState.start_act_2()
    verify_deck(CampaignState.act_2_city_id(1))
    verify_deck(CampaignState.act_2_city_id(3))
    verify_deck("Act 2 Boss")

func verify_deck(city_id: String) -> void:
    var deck := EnemyDeck.new().build(city_id)
    var rule := CampaignBalance.city_rule(city_id)
    assert(CampaignBalance.city_slots(city_id) == rule["slots"])
    if rule.has("deck"):
        assert(deck == rule["deck"])
        return
    assert(deck.size() == rule["count"])
    assert(value(deck) == rule["value"])

func verify_act_1_boss_decks() -> void:
    CampaignState.loyalty["Nobility"] = -1
    verify_group_deck("Nobility")
    CampaignState.loyalty = {"Peasants": -1, "Nobility": 0}
    verify_group_deck("Peasants")

func verify_group_deck(group: String) -> void:
    var deck := EnemyDeck.new().build("Act 1 Boss")
    var rule := CampaignBalance.city_rule("Act 1 Boss")
    assert(deck.size() == rule["%s_count" % group.to_lower()])
    assert(value(deck) == rule["%s_value" % group.to_lower()])
    assert(deck.all(func(card_name: String) -> bool: return RewardRules.belongs_to(card_name, group)))

func verify_act_2_keeps_deck() -> void:
    var deck := CampaignState.player_deck.map(func(card: CampaignCard) -> String: return card.card_name)
    CampaignState.start_act_2()
    assert(CampaignState.player_deck.map(func(card: CampaignCard) -> String: return card.card_name) == deck)

func value(deck: Array[String]) -> int:
    return deck.reduce(func(total: int, card_name: String) -> int: return total + CardCatalog.get_value(card_name), 0)

func verify_factions() -> void:
    CampaignState.start_in_act_2 = true
    CampaignState.reset()
    CampaignState.start_act_2()
    for index in CampaignState.player_deck.size():
        var expected := CampaignState.Faction.ENGLISH if index % 2 == 0 else CampaignState.Faction.HRE
        assert(CampaignState.player_deck[index].faction == expected)
    CampaignState.declare_war(CampaignState.Faction.ENGLISH)
    assert(CampaignState.battlefield_faction() == CampaignState.Faction.ENGLISH)
    CampaignState.selected_city = "Act 2 Boss"
    assert(CampaignState.battlefield_faction() == CampaignState.Faction.HRE)

extends SceneTree

func _initialize() -> void:
    verify_decks()
    verify_factions()
    quit()

func verify_decks() -> void:
    CampaignState.start_in_act_2 = false
    CampaignState.reset()
    verify_deck(CampaignState.act_1_city_id(1), EnemyDeck.ACT_1_CITY_DECKS)
    verify_deck(CampaignState.act_1_city_id(3), EnemyDeck.ACT_1_CITY_RULES)
    verify_act_1_boss_decks()
    verify_act_2_keeps_deck()
    CampaignState.start_act_2()
    verify_deck(CampaignState.act_2_city_id(1), EnemyDeck.ACT_2_CITY_DECKS)
    verify_deck(CampaignState.act_2_city_id(3), EnemyDeck.ACT_2_CITY_RULES)
    verify_deck("Act 2 Boss", EnemyDeck.ACT_2_CITY_RULES)

func verify_deck(city_id: String, rules: Dictionary) -> void:
    var deck := EnemyDeck.new().build(city_id)
    var rule: Array = rules[city_id]
    if rule[0] is String:
        assert(deck == rule)
        return
    assert(deck.size() == rule[0])
    assert(value(deck) == rule[1])

func verify_act_1_boss_decks() -> void:
    CampaignState.loyalty["Nobility"] = -1
    verify_group_deck("Nobility", EnemyDeck.ACT_1_BOSS_NOBILITY_RULE)
    CampaignState.loyalty = {"Peasants": -1, "Nobility": 0}
    verify_group_deck("Peasants", EnemyDeck.ACT_1_BOSS_PEASANTS_RULE)

func verify_group_deck(group: String, rule: Array) -> void:
    var deck := EnemyDeck.new().build("Act 1 Boss")
    assert(deck.size() == rule[0])
    assert(value(deck) == rule[1])
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

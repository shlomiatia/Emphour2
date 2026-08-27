class_name EnemyDeck extends Resource

func build(city_id: String) -> Array[String]:
    if city_id.is_empty():
        return CampaignBalance.deck("default_enemy")
    var boss_deck := act_1_boss_deck(city_id)
    if !boss_deck.is_empty():
        return boss_deck
    return build_rule(CampaignBalance.city_rule(city_id), city_id)

func build_rule(rule: Dictionary, city_id: String) -> Array[String]:
    if rule.has("deck"):
        var deck: Array[String]
        deck.assign(rule["deck"])
        return deck
    if rule.has("count") && rule.has("value"):
        return generate(int(rule["count"]), int(rule["value"]), get_pool(city_id))
    push_error("No enemy deck rule for %s" % city_id)
    return []

func act_1_boss_deck(city_id: String) -> Array[String]:
    if CampaignState.is_act_2() || city_id != "Act 1 Boss":
        return []
    var group := "Nobility" if CampaignState.loyalty["Nobility"] < 0 else "Peasants" if CampaignState.loyalty["Peasants"] < 0 else ""
    if group.is_empty():
        return []
    var rule := CampaignBalance.city_rule(city_id)
    return generate(int(rule["%s_count" % group.to_lower()]), int(rule["%s_value" % group.to_lower()]), group_pool(city_id, group))

static func group_pool(city_id: String, group: String) -> Array[String]:
    return get_pool(city_id).filter(func(card_name: String) -> bool: return RewardRules.belongs_to(card_name, group))

static func get_pool(city_id: String) -> Array[String]:
    var pool := CardCatalog.CARDS.duplicate()
    for card_name in CampaignBalance.city_exclusions(city_id):
        pool.erase(card_name)
    return pool

static func generate(count: int, value: int, pool: Array[String]) -> Array[String]:
    return EnemyDeckPicker.generate(count, value, pool)

class_name EnemyDeck extends Resource

func build(city_id: String) -> Array[String]:
    if city_id.is_empty():
        return CampaignBalance.deck("default_enemy")
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

static func get_pool(city_id: String) -> Array[String]:
    var pool := CardCatalog.CARDS.duplicate()
    for card_name in CampaignBalance.city_exclusions(city_id):
        pool.erase(card_name)
    return pool

static func generate(count: int, value: int, pool: Array[String]) -> Array[String]:
    return EnemyDeckPicker.generate(count, value, pool)

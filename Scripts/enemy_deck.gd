class_name EnemyDeck extends Resource

const ACT_1_CITY_DECKS := {"Act 1 City 1": ["Light Cavalry", "Militia", "Militia"], "Act 1 City 2": ["Archer", "Axeman", "Mantlet", "Stakes", "Militia", "Militia"]}
const ACT_1_CITY_RULES := {"Act 1 City 3": [10, 12], "Act 1 City 4": [12, 14], "Act 1 City 5": [10, 17], "Act 1 City 6": [13, 18], "Act 1 Boss": [13, 20]}
const ACT_2_CITY_DECKS := {"Act 2 City 1": ["Light Cavalry", "Militia", "Militia"], "Act 2 City 2": ["Archer", "Axeman", "Mantlet", "Stakes", "Militia", "Militia"]}
const ACT_2_CITY_RULES := {"Act 2 City 3": [10, 12], "Act 2 City 4": [12, 14], "Act 2 City 5": [10, 17], "Act 2 City 6": [13, 18], "Act 2 Boss": [13, 20]}
const DEFAULT_DECK: Array[String] = ["Archer", "Militia", "Militia"]

func build(city_id: String) -> Array[String]:
    if city_id.is_empty():
        return DEFAULT_DECK.duplicate()
    if fixed_decks().has(city_id):
        var deck: Array[String]
        deck.assign(fixed_decks()[city_id])
        return deck
    if city_rules().has(city_id):
        var rule: Array = city_rules()[city_id]
        return generate(rule[0], rule[1], get_pool(city_id))
    push_error("No enemy deck rule for %s" % city_id)
    return []

func fixed_decks() -> Dictionary:
    return ACT_2_CITY_DECKS if CampaignState.is_act_2() else ACT_1_CITY_DECKS

func city_rules() -> Dictionary:
    return ACT_2_CITY_RULES if CampaignState.is_act_2() else ACT_1_CITY_RULES

static func get_pool(city_id: String) -> Array[String]:
    var pool := CardCatalog.CARDS.duplicate()
    if !CampaignState.crossbowman_unlocked(city_id):
        pool.erase("Crossbowman")
    return pool

static func generate(count: int, value: int, pool: Array[String]) -> Array[String]:
    return EnemyDeckPicker.generate(count, value, pool)

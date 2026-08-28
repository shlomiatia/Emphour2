class_name CampaignBalance extends RefCounted

const DATA_PATH := "res://Resources/campaign_balance.cfg"

static var data := ConfigFile.new()
static var loaded := false

static func config() -> ConfigFile:
    if !loaded:
        assert(data.load(DATA_PATH) == OK)
        loaded = true
    return data

static func strings(section: String, key: String) -> Array[String]:
    var result: Array[String]
    for value in config().get_value(section, key, []):
        result.append(value)
    return result

static func city_rule(city_id: String) -> Dictionary:
    return config().get_value("cities", city_id, {}) as Dictionary

static func city_slots(city_id: String) -> int:
    return int(city_rule(city_id).get("slots", 3))

static func city_exclusions(city_id: String) -> Array[String]:
    var result: Array[String]
    for card_name in city_rule(city_id).get("exclude", []):
        result.append(card_name)
    return result

static func reward_exclusions(city_id: String) -> Array[String]:
    var result: Array[String]
    for card_name in city_rule(city_id).get("reward_exclude", []):
        result.append(card_name)
    return result

static func deck(name: String) -> Array[String]:
    return strings("starting_decks", name)

static func tier_cards(tier: int) -> Array[String]:
    return strings("tiers", str(tier))

static func tier_of(card_name: String) -> int:
    for tier in 4:
        if tier_cards(tier + 1).has(card_name):
            return tier + 1
    return 0

static func tier_one_weight(card_name: String) -> int:
    return int(config().get_value("tier_1_weights", card_name, 1))

static func upgrades(card_name: String) -> String:
    return config().get_value("upgrades", card_name, "") as String

static func rewards(key: String) -> Array[String]:
    return strings("rewards", key)

static func loyalty_chances(loyalty: int) -> Array:
    return config().get_value("loyalty_chances", str(loyalty), []) as Array

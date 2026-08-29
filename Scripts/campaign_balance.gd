class_name CampaignBalance extends RefCounted

const DATA := preload("res://Scripts/campaign_balance_data.gd").DATA

static func strings(section: String, key: String) -> Array[String]:
    var result: Array[String]
    for item in value(section, key, []):
        result.append(item)
    return result

static func city_rule(city_id: String) -> Dictionary:
    return value("cities", city_id, {}) as Dictionary

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
    return int(value("tier_1_weights", card_name, 1))

static func upgrades(card_name: String) -> String:
    return value("upgrades", card_name, "") as String

static func rewards(key: String) -> Array[String]:
    return strings("rewards", key)

static func loyalty_chances(loyalty: int) -> Array:
    return value("loyalty_chances", str(loyalty), []) as Array

static func value(section: String, key: String, default: Variant) -> Variant:
    return DATA.get(section, {}).get(key, default)

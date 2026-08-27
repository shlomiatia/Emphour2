class_name RewardRules extends RefCounted

const DATA_PATH := "res://Resources/reward_data.cfg"
const TIERS := {
    1: ["Archer", "Mantlet", "Stakes"],
    2: ["Crossbowman", "Horse Archer", "Light Cavalry", "Axeman", "Swordman", "Spearman"],
    3: ["Foot Knight", "Lancer", "Heavy Cavalry"],
    4: ["Knight"]
}
const NOBILITY := ["Horse Archer", "Light Cavalry", "Foot Knight", "Lancer", "Heavy Cavalry", "Knight"]

static func create_offer(group: String, loyalty: int, deck: Array[String], crossbowman_unlocked := true) -> Dictionary:
    var reward := get_reward(group, loyalty)
    var old_name := pick_old_card(group, reward, deck, crossbowman_unlocked)
    var choices := get_upgrade_cards(group, old_name, reward["tier"], crossbowman_unlocked) if !old_name.is_empty() else get_group_cards(group, reward["tier"], crossbowman_unlocked)
    return {"old": old_name, "new": choices.pick_random()}

static func create_final_offer(group: String, upgrade: bool, deck: Array[String]) -> Dictionary:
    var old_name := pick_final_old(deck) if upgrade else ""
    var tier := 4 if group == "Nobility" else 2
    var card_name := "Knight"
    if group == "Peasants":
        card_name = get_group_cards(group, tier).pick_random()
    return {"old": old_name, "new": card_name, "title": group if !upgrade else "%s Upgrade" % group}

static func apply_offer(offer: Dictionary, deck: Array[String]) -> void:
    if !offer["old"].is_empty():
        deck.erase(offer["old"])
    deck.append(offer["new"])

static func get_reward(group: String, loyalty: int) -> Dictionary:
    var data := get_data()
    var parts := (data.get_value("rewards", "%s_%s" % [group, clampi(loyalty, 0, 5)]) as String).split(":")
    return {"upgrade": parts[0] == "upgrade", "from": int(parts[1]) if parts.size() == 3 else 0, "tier": int(parts[-1])}

static func pick_final_old(deck: Array[String]) -> String:
    var choices := deck.filter(func(card: String) -> bool: return TIERS[1].has(card))
    return "" if choices.is_empty() else choices.pick_random()

static func pick_old_card(group: String, reward: Dictionary, deck: Array[String], crossbowman_unlocked: bool) -> String:
    if !reward["upgrade"]:
        return ""
    var tiers := TIERS.keys()
    tiers.sort()
    for tier in tiers:
        if tier < reward["from"] || tier >= reward["tier"]:
            continue
        var choices := deck.filter(func(card: String) -> bool: return TIERS[tier].has(card) && !get_upgrade_cards(group, card, reward["tier"], crossbowman_unlocked).is_empty())
        if !choices.is_empty():
            return choices.pick_random()
    return ""

static func get_upgrade_cards(group: String, card_name: String, tier: int, crossbowman_unlocked := true) -> Array[String]:
    var upgrade := get_data().get_value("upgrades", card_name, "") as String
    var cards: Array[String]
    cards.assign(TIERS[tier])
    return cards.filter(func(card: String) -> bool: return card_unlocked(card, crossbowman_unlocked) && belongs_to(card, group) && (upgrade == "all" || upgrade.split(",").has(card)))

static func get_group_cards(group: String, tier: int, crossbowman_unlocked := true) -> Array[String]:
    var choices: Array[String]
    choices.assign(TIERS[tier].filter(func(card: String) -> bool: return card_unlocked(card, crossbowman_unlocked) && belongs_to(card, group)))
    return choices

static func card_unlocked(card_name: String, crossbowman_unlocked: bool) -> bool:
    return card_name != "Crossbowman" || crossbowman_unlocked

static func belongs_to(card_name: String, group: String) -> bool:
    return NOBILITY.has(card_name) == (group == "Nobility")

static func get_data() -> ConfigFile:
    var data := ConfigFile.new()
    data.load(DATA_PATH)
    return data

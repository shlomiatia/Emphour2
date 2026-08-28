class_name RewardRules extends RefCounted

const NOBILITY := ["Horse Archer", "Light Cavalry", "Foot Knight", "Lancer", "Heavy Cavalry", "Knight"]

static func create_offer(group: String, city_index: int, deck: Array) -> Dictionary:
    var reward := reward_rule("Act1", group, reward_level(group, city_index))
    var excluded := CampaignBalance.reward_exclusions(CampaignState.selected_city)
    var old_name := pick_old_card(group, reward, deck, excluded)
    var choices := target_cards(group, reward, old_name, excluded)
    assert(!choices.is_empty(), "No eligible %s reward cards" % group)
    return {"old": old_name, "new": choices.pick_random()}

static func create_boss_offer(group: String, index: int, deck: Array) -> Dictionary:
    var reward := reward_rule("Act1Boss", group, index)
    var excluded := CampaignBalance.reward_exclusions(CampaignState.selected_city)
    var old_name := pick_old_card(group, reward, deck, excluded)
    var choices := target_cards(group, reward, old_name, excluded)
    assert(!choices.is_empty(), "No eligible %s reward cards" % group)
    return {"old": old_name, "new": choices.pick_random(), "title": group}

static func reward_level(group: String, city_index: int) -> int:
    var other := "Nobility" if group == "Peasants" else "Peasants"
    return maxi(1, city_index - 1) if CampaignState.loyalty[group] < CampaignState.loyalty[other] else city_index

static func reward_rule(scope: String, group: String, index: int) -> Dictionary:
    var key := clampi(index, 1, 5) if scope == "Act1" else clampi(index, 1, 2)
    return parse_rule(CampaignBalance.rewards("%s_%s_%d" % [scope, group, key]).pick_random())

static func parse_rule(value: String) -> Dictionary:
    var parts := value.split(":")
    var upgrade := parts[0] == "upgrade"
    var target_index := 2 if upgrade else 1
    var target := parts[target_index]
    return {"upgrade": upgrade, "from": int(parts[1]) if upgrade else 0, "target": target, "specific": !target.is_valid_int(), "excluded": exclusions(parts, target_index)}

static func exclusions(parts: PackedStringArray, target_index: int) -> Array[String]:
    var result: Array[String]
    for card_name in parts.slice(target_index + 2):
        result.append(card_name)
    return result

static func apply_offer(offer: Dictionary, deck: Array) -> void:
    if offer.has("source") && offer["source"] != null:
        deck.erase(offer["source"])
        deck.append(CampaignCard.new(offer["new"], offer["faction"]))
        return
    for entry in deck:
        if card_name(entry) == offer["old"]:
            deck.erase(entry)
            break
    deck.append(CampaignCard.new(offer["new"], offer.get("faction", CampaignState.Faction.FRANKS)))

static func pick_old_card(group: String, reward: Dictionary, deck: Array, excluded: Array[String]) -> String:
    if !reward["upgrade"]:
        return ""
    var target_tier := target_tier(reward)
    for tier in target_tier - 1:
        if tier + 1 < reward["from"]:
            continue
        var choices := deck.filter(func(entry: Variant) -> bool: return tier_cards(tier + 1).has(card_name(entry)) && !target_cards(group, reward, card_name(entry), excluded).is_empty())
        if !choices.is_empty():
            return card_name(choices.pick_random())
    return ""

static func target_cards(group: String, reward: Dictionary, old_name := "", excluded: Array[String] = []) -> Array[String]:
    var result: Array[String]
    var cards := [reward["target"]] if reward["specific"] else tier_cards(target_tier(reward))
    for card_name in cards:
        if !reward["specific"] && (excluded.has(card_name) || reward["excluded"].has(card_name)):
            continue
        if belongs_to(card_name, group) && (old_name.is_empty() || can_upgrade(old_name, card_name)):
            result.append(card_name)
    return result

static func target_tier(reward: Dictionary) -> int:
    return CampaignBalance.tier_of(reward["target"]) if reward["specific"] else int(reward["target"])

static func tier_cards(tier: int) -> Array[String]:
    return CampaignBalance.tier_cards(tier)

static func can_upgrade(old_name: String, new_name: String) -> bool:
    var upgrade := CampaignBalance.upgrades(old_name)
    return upgrade == "all" || upgrade.split(",").has(new_name)

static func belongs_to(card_name: String, group: String) -> bool:
    return NOBILITY.has(card_name) == (group == "Nobility")

static func card_name(entry: Variant) -> String:
    return entry.card_name if entry is CampaignCard else entry

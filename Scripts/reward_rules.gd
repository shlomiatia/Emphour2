class_name RewardRules extends RefCounted

const NOBILITY := ["Horse Archer", "Light Cavalry", "Foot Knight", "Lancer", "Heavy Cavalry", "Knight"]

static func create_offer(group: String, loyalty: int, deck: Array) -> Dictionary:
    var reward := reward_rule("Act1", group, loyalty)
    var excluded := CampaignBalance.city_exclusions(CampaignState.selected_city)
    var old_name := pick_old_card(group, reward, deck, excluded)
    var choices := target_cards(group, reward, old_name, excluded)
    return {"old": old_name, "new": choices.pick_random()}

static func create_boss_offer(group: String, index: int, deck: Array) -> Dictionary:
    var reward := reward_rule("Act1Boss", group, index)
    var excluded := CampaignBalance.city_exclusions(CampaignState.selected_city)
    var old_name := pick_old_card(group, reward, deck, excluded)
    var choices := target_cards(group, reward, old_name, excluded)
    return {"old": old_name, "new": choices.pick_random(), "title": group}

static func reward_rule(scope: String, group: String, index: int) -> Dictionary:
    return parse_rule(CampaignBalance.rewards("%s_%s_%d" % [scope, group, clampi(index, 0, 5)]).pick_random())

static func parse_rule(value: String) -> Dictionary:
    var parts := value.split(":")
    var target := parts[-1]
    return {"upgrade": parts[0] == "upgrade", "from": int(parts[1]) if parts.size() == 3 else 0, "target": target, "specific": !target.is_valid_int()}

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
        if !reward["specific"] && excluded.has(card_name):
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

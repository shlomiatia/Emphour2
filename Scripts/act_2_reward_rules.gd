class_name Act2RewardRules extends RefCounted

static func create_offer(faction: CampaignState.Faction, level: int, deck: Array) -> Dictionary:
    var reward: Dictionary = rewards(level).pick_random()
    var source := pick_source(faction, reward, deck)
    var card_name := pick_card(reward, source)
    return {"old": "" if source == null else source.card_name, "old_faction": -1 if source == null else source.faction, "source": source, "new": card_name, "faction": faction, "title": CampaignState.faction_name(faction)}

static func rewards(level: int) -> Array[Dictionary]:
    if level == 5:
        return [{"new": "Crossbowman"}, {"from": 1, "new": "Crossbowman"}, {"tier": 4}, {"from": 3, "tier": 4}]
    if level == 6:
        return [{"new": "Crossbowman"}, {"from": 1, "new": "Crossbowman"}, {"tier": 4}, {"from": 2, "tier": 4}]
    return [{"tier": 1}] if level == 1 else [{"from": level - 1, "tier": level}]

static func pick_source(faction: int, reward: Dictionary, deck: Array) -> CampaignCard:
    if !reward.has("from"):
        return null
    for source_faction in [CampaignState.Faction.FRANKS, faction, CampaignState.other_foreign_faction(faction)]:
        var cards := deck.filter(func(entry: CampaignCard) -> bool: return entry.faction == source_faction && eligible(entry.card_name, reward))
        if !cards.is_empty():
            return cards.pick_random()
    return null

static func pick_card(reward: Dictionary, source: CampaignCard) -> String:
    if reward.has("new"):
        return reward["new"]
    var cards: Array[String]
    cards.assign(RewardRules.TIERS[reward["tier"]])
    if source != null:
        cards = cards.filter(func(card_name: String) -> bool: return can_upgrade(source.card_name, card_name))
    return cards.pick_random()

static func eligible(card_name: String, reward: Dictionary) -> bool:
    if !RewardRules.TIERS[reward["from"]].has(card_name):
        return false
    if reward.has("new"):
        return can_upgrade(card_name, reward["new"])
    return RewardRules.TIERS[reward["tier"]].any(func(new_name: String) -> bool: return can_upgrade(card_name, new_name))

static func can_upgrade(old_name: String, new_name: String) -> bool:
    var upgrade := RewardRules.get_data().get_value("upgrades", old_name, "") as String
    return upgrade == "all" || upgrade.split(",").has(new_name)

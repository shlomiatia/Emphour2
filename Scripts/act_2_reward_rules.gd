class_name Act2RewardRules extends RefCounted

static func create_offer(faction: CampaignState.Faction, city_index: int, deck: Array) -> Dictionary:
    var relation := "War" if faction == CampaignState.faction_at_war() else "Ally"
    var reward := RewardRules.parse_rule(rewards(relation, city_index).pick_random())
    var source := pick_source(faction, reward, deck)
    return {"old": "" if source == null else source.card_name, "old_faction": -1 if source == null else source.faction, "source": source, "new": pick_card(reward, source), "faction": faction, "title": CampaignState.faction_name(faction)}

static func rewards(relation: String, city_index: int) -> Array[String]:
    return CampaignBalance.rewards("Act2_%s_%d" % [relation, city_index])

static func pick_source(faction: int, reward: Dictionary, deck: Array) -> CampaignCard:
    if !reward["upgrade"]:
        return null
    for source_faction in [CampaignState.Faction.FRANKS, faction, CampaignState.other_foreign_faction(faction)]:
        var cards := deck.filter(func(entry: CampaignCard) -> bool: return entry.faction == source_faction && eligible(entry.card_name, reward))
        if !cards.is_empty():
            return cards.pick_random()
    return null

static func pick_card(reward: Dictionary, source: CampaignCard) -> String:
    var cards := available_cards(reward)
    if source != null:
        cards = cards.filter(func(card_name: String) -> bool: return RewardRules.can_upgrade(source.card_name, card_name))
    return cards.pick_random()

static func eligible(card_name: String, reward: Dictionary) -> bool:
    if !RewardRules.tier_cards(reward["from"]).has(card_name):
        return false
    var cards := available_cards(reward)
    return cards.any(func(new_name: String) -> bool: return RewardRules.can_upgrade(card_name, new_name))

static func available_cards(reward: Dictionary) -> Array:
    if reward["specific"]:
        return [reward["target"]]
    var excluded := CampaignBalance.city_exclusions(CampaignState.selected_city)
    return RewardRules.tier_cards(RewardRules.target_tier(reward)).filter(func(card_name: String) -> bool: return !excluded.has(card_name))

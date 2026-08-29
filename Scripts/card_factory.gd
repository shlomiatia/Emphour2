class_name CardFactory extends RefCounted

const CARD_SCENE := preload("res://Entities/Card/Card.tscn")

static func create_campaign_card(entry: CampaignCard, side: int, group_identity_visible := true) -> Card:
    var card := create(entry.card_name, side, entry.faction, group_identity_visible)
    card.deck_entry = entry
    return card

static func create(card_name: String, side: int, faction := -1, group_identity_visible := true) -> Card:
    var card := CARD_SCENE.instantiate() as Card
    card.card_name = card_name
    card.side = side
    card.faction = faction if faction != -1 else CampaignState.Faction.FRANKS if side == GameRules.Side.PLAYER else CampaignState.Faction.REBELS
    card.group_identity_visible = group_identity_visible
    return card

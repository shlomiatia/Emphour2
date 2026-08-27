class_name CardFactory extends RefCounted

const CARD_SCENE := preload("res://Entities/Card/Card.tscn")

static func create(card_name: String, side: int, faction := -1) -> Card:
    var card := CARD_SCENE.instantiate() as Card
    card.card_name = card_name
    card.side = side
    card.faction = faction if faction != -1 else CampaignState.Faction.FRANKS if side == GameRules.Side.PLAYER else CampaignState.Faction.REBELS
    return card

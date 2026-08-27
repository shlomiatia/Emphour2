class_name CardFactory extends RefCounted

const CARD_SCENE := preload("res://Entities/Card/Card.tscn")

static func create(card_name: String, side: int) -> Card:
    var card := CARD_SCENE.instantiate() as Card
    card.card_name = card_name
    card.side = side
    return card

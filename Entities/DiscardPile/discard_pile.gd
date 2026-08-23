class_name DiscardPile extends Node2D

@export var side: int = GameRules.Side.PLAYER
@onready var anchor: Node2D = $CardAnchor
@onready var count_label: Label = $Count

func add_card(card: Card) -> void:
    card.reparent(anchor)
    card.position = Vector2.ZERO
    card.rotation = 0.0
    card.scale = Card.DISCARD_SCALE
    card.draggable = false
    card.set_selectable(false)
    card.set_hidden(false)
    card.z_index = anchor.get_child_count()
    count_label.text = str(anchor.get_child_count())

func contains_point(point: Vector2) -> bool:
    return Rect2(-65, -88, 130, 176).has_point(to_local(point))

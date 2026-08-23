class_name CardHand extends Node2D

@export var side: int = GameRules.Side.PLAYER
@export var face_down := false
@export var width := 1040.0
@export var card_scale := Card.HAND_SCALE

func _process(delta: float) -> void:
    arrange_cards(delta)

func arrange_cards(delta: float) -> void:
    var cards := get_cards()
    var spacing := minf(118.0, width / maxf(cards.size() - 1, 1))
    var left := -spacing * float(cards.size() - 1) / 2.0
    for index in cards.size():
        move_card(cards[index], Vector2(left + spacing * index, 0), delta, index)

func move_card(card: Card, target: Vector2, delta: float, index: int) -> void:
    if card.dragging:
        return
    card.position = card.position.lerp(target, minf(delta * 12.0, 1.0))
    card.scale = card.scale.lerp(card_scale, minf(delta * 12.0, 1.0))
    card.rotation = lerp_angle(card.rotation, 0.0, minf(delta * 12.0, 1.0))
    card.z_index = index + 5

func add_card(card: Card) -> void:
    if card.get_parent():
        card.reparent(self)
    else:
        add_child(card)
    card.set_hidden(face_down)
    card.scale = card_scale

func get_cards() -> Array[Card]:
    var result: Array[Card]
    for child in get_children():
        if child is Card:
            result.append(child)
    return result

func get_card_count() -> int:
    return get_cards().size()

func set_draggable(value: bool) -> void:
    for card in get_cards():
        card.draggable = value

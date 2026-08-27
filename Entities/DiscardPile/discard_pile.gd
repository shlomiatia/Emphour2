class_name DiscardPile extends Node2D

@onready var count_label: Label = $Count
@onready var icon: Sprite2D = $Icon

var targetable := false
var hovering := false
var dragged_card: Card
var card_count := 0

signal target_chosen

func _process(_delta: float) -> void:
    set_hovering(overlaps(dragged_card) if dragged_card else contains_point(get_viewport().get_mouse_position()))

func _unhandled_input(event: InputEvent) -> void:
    if targetable && event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed && contains_point(event.position):
        target_chosen.emit()
        get_viewport().set_input_as_handled()

func add_card(card: Card, free := true) -> void:
    card_count += 1
    count_label.text = str(card_count)
    if free:
        card.queue_free()

func set_targetable(value: bool) -> void:
    targetable = value
    if !value:
        dragged_card = null
    refresh_border()

func set_dragged_card(card: Card) -> void:
    dragged_card = card

func set_hovering(value: bool) -> void:
    if hovering == value:
        return
    hovering = value
    refresh_border()

func refresh_border() -> void:
    icon.modulate = Card.HIGHLIGHT_COLOR if targetable && hovering else Color.WHITE

func contains_point(point: Vector2) -> bool:
    return Rect2(-Card.SIZE / 2.0, Card.SIZE).has_point(to_local(point))

func overlaps(card: Card) -> bool:
    return card && Rect2(global_position - Card.SIZE / 2.0, Card.SIZE).intersects(card.get_global_rect())

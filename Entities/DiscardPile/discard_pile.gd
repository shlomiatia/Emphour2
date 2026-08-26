class_name DiscardPile extends Node2D

@export var side: int = GameRules.Side.PLAYER
@onready var anchor: Node2D = $CardAnchor
@onready var count_label: Label = $Count
@onready var border: NinePatchRect = $Border
@onready var icon: Sprite2D = $Icon

var targetable := false
var hovering := false
var dragged_card: Card
var card_count := 0

signal target_chosen

func _process(delta: float) -> void:
    for card in anchor.get_children():
        move_card(card, delta)
    set_hovering(overlaps(dragged_card) if dragged_card else contains_point(get_viewport().get_mouse_position()))

func _unhandled_input(event: InputEvent) -> void:
    if targetable && event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed && contains_point(event.position):
        target_chosen.emit()
        get_viewport().set_input_as_handled()

func move_card(card: Card, delta: float) -> void:
    var weight := minf(delta * 10.0, 1.0)
    card.position = card.position.lerp(Vector2.ZERO, weight)
    card.rotation = lerp_angle(card.rotation, 0.0, weight)

func add_card(card: Card, free := true) -> void:
    card_count += 1
    count_label.text = str(card_count)
    if free:
        card.queue_free()

func add_defeated(card: Card) -> void:
    card_count += 1
    count_label.text = str(card_count)
    card.queue_free()

func set_targetable(value: bool) -> void:
    targetable = value
    if !value:
        dragged_card = null
    refresh_border()

func set_dragged_card(card: Card) -> void:
    dragged_card = card

func set_hovering(value: bool) -> void:
    hovering = value
    refresh_border()

func refresh_border() -> void:
    border.hide()
    icon.modulate = Color("#fee761") if targetable && hovering else Color.WHITE

func contains_point(point: Vector2) -> bool:
    return Rect2(-91, -126.5, 182, 253).has_point(to_local(point))

func overlaps(card: Card) -> bool:
    return card && Rect2(global_position - Vector2(91, 126.5), Vector2(182, 253)).intersects(card.get_global_rect())

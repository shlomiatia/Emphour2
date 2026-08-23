class_name HandInteraction extends Node

const DRAG_MIN_TIME := 100

var hand: CardHand
var dragging_card: Card
var hover_blocked_card: Card
var drag_offset := Vector2.ZERO
var drag_start_time := 0

func setup(card_hand: CardHand) -> void:
    hand = card_hand

func _process(_delta: float) -> void:
    if hand:
        process_pointer()

func _unhandled_input(event: InputEvent) -> void:
    if !hand || !hand.hover_enabled:
        return
    if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
        cancel_drag()
    elif event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
        handle_left_button(event)

func process_pointer() -> void:
    if dragging_card:
        clear_hover()
        dragging_card.global_position = hand.get_viewport().get_mouse_position() + drag_offset
        dragging_card.z_index = 100
    else:
        update_hover(hand.get_viewport().get_mouse_position())

func handle_left_button(event: InputEventMouseButton) -> void:
    if event.pressed && !dragging_card:
        start_drag(event.position)
    elif !event.pressed && dragging_card && Time.get_ticks_msec() - drag_start_time > DRAG_MIN_TIME:
        release_drag(event.position)

func start_drag(point: Vector2) -> void:
    var card := hand.get_card_at(point)
    if !card || !card.draggable:
        return
    dragging_card = card
    hover_blocked_card = null
    dragging_card.dragging = true
    drag_offset = card.global_position - point
    drag_start_time = Time.get_ticks_msec()
    hand.card_clicked.emit(card)
    hand.get_viewport().set_input_as_handled()

func release_drag(point: Vector2) -> void:
    var card := dragging_card
    card.global_position = point + drag_offset
    dragging_card = null
    card.dragging = false
    hand.card_released.emit(card)
    if card.get_parent() == hand:
        hover_blocked_card = card
    hand.get_viewport().set_input_as_handled()

func cancel_drag() -> void:
    if !dragging_card:
        return
    dragging_card.dragging = false
    hover_blocked_card = dragging_card
    dragging_card = null
    hand.card_cancelled.emit()
    hand.get_viewport().set_input_as_handled()

func clear_hover() -> void:
    for card in hand.get_cards():
        card.set_hovering(false)

func update_hover(point: Vector2) -> void:
    if hover_blocked_card && !hover_blocked_card.contains_point(point):
        hover_blocked_card = null
    var hovered := hand.get_card_at(point) if hand.hover_enabled else null
    if hovered == hover_blocked_card:
        hovered = null
    for card in hand.get_cards():
        card.set_hovering(card == hovered)

func stop() -> void:
    if !dragging_card:
        return
    dragging_card.dragging = false
    dragging_card = null

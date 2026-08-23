class_name Board extends Node2D

const ROW_COUNT := 4

@export var player_row := 2
@export var enemy_row := 1
@export_range(1, 5) var slot_count := 3
@export var row_spacing := 8.0
@onready var movement: FrontMovement = $FrontMovement

var dragged_card: Card
var highlighted_target: CardSlot

signal target_chosen(slot: CardSlot)

func _ready() -> void:
    movement.setup(self)
    refresh_slots()
    refresh_rows()

func _process(_delta: float) -> void:
    var target := get_overlap_target(dragged_card) if dragged_card else get_target_at(get_viewport().get_mouse_position())
    highlighted_target = target
    for slot in get_slots():
        slot.set_hovering(slot == target)

func _unhandled_input(event: InputEvent) -> void:
    if !(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed):
        return
    var target := get_target_at(event.position)
    if target:
        target_chosen.emit(target)
        get_viewport().set_input_as_handled()

func refresh_rows() -> void:
    for slot in get_slots():
        slot.set_active(slot.row == player_row, slot.row == enemy_row)

func refresh_slots() -> void:
    var rows := $Rows.get_children()
    var row_height := get_row_height()
    for row_index in rows.size():
        var row := rows[row_index] as Node2D
        row.position.y = (row_index - (rows.size() - 1) / 2.0) * row_height
        var slots := row.get_children()
        var first := (slots.size() - slot_count) / 2
        for index in slots.size():
            var slot := slots[index] as CardSlot
            slot.visible = index >= first && index < first + slot_count

func get_row_height() -> float:
    var slot := $Rows.get_child(0).get_child(0) as CardSlot
    return slot.slot_size.y + row_spacing

func play_leftmost(card: Card, side: int) -> bool:
    for slot in get_row_slots(get_side_row(side)):
        if !slot.get_card():
            slot.place(card)
            return true
    return false

func replace_at(card: Card, slot: CardSlot, side: int) -> Card:
    if slot.row != get_side_row(side) || !slot.get_card():
        return null
    var replaced := slot.get_card()
    replaced.reparent(self)
    slot.place(card)
    return replaced

func replace_first(card: Card, side: int) -> Card:
    var slot := get_row_slots(get_side_row(side))[0]
    var replaced := slot.get_card()
    replaced.reparent(self)
    slot.place(card)
    return replaced

func is_full(side: int) -> bool:
    return get_row_slots(get_side_row(side)).all(func(slot: CardSlot) -> bool: return slot.get_card() != null)

func get_cards(side: int) -> Array[Card]:
    var result: Array[Card]
    for slot in get_row_slots(get_side_row(side)):
        if slot.get_card():
            result.append(slot.get_card())
    return result

func reveal_enemy_cards() -> void:
    for card in get_cards(GameRules.Side.ENEMY):
        card.set_hidden(false)

func enable_player_targets(full_row: bool) -> void:
    clear_targets()
    for slot in get_row_slots(player_row):
        if full_row || !slot.get_card():
            slot.set_targetable(true)

func enable_card_targets(cards: Array[Card]) -> void:
    clear_targets()
    for slot in get_slots():
        var card := slot.get_card()
        slot.set_targetable(cards.has(card))
        if card:
            card.set_disabled(!cards.has(card))

func set_dragged_card(card: Card) -> void:
    dragged_card = card

func clear_targets() -> void:
    dragged_card = null
    highlighted_target = null
    for slot in get_slots():
        slot.set_targetable(false)
        if slot.get_card():
            slot.get_card().set_disabled(false)

func get_target_at(point: Vector2) -> CardSlot:
    for slot in get_slots():
        if slot.targetable && slot.contains_point(point):
            return slot
    return null

func get_overlap_target(card: Card) -> CardSlot:
    if !card:
        return null
    var targets := get_slots().filter(func(slot: CardSlot) -> bool: return slot.targetable && slot.get_global_rect().intersects(card.get_global_rect()))
    targets.sort_custom(func(a: CardSlot, b: CardSlot) -> bool: return a.global_position.distance_to(card.global_position) < b.global_position.distance_to(card.global_position))
    return targets[0] if !targets.is_empty() else null

func advance(winner: int) -> Dictionary:
    return movement.advance(winner)

func advance_to_end(winner: int) -> void:
    movement.advance_to_end(winner)

func get_side_row(side: int) -> int:
    return player_row if side == GameRules.Side.PLAYER else enemy_row

func set_side_row(side: int, value: int) -> void:
    if side == GameRules.Side.PLAYER:
        player_row = value
    else:
        enemy_row = value

func get_row_slots(row: int) -> Array[CardSlot]:
    return get_slots().filter(func(slot: CardSlot) -> bool: return slot.row == row && slot.visible)

func get_slots() -> Array[CardSlot]:
    var result: Array[CardSlot]
    for row in $Rows.get_children():
        for slot in row.get_children():
            result.append(slot)
    return result

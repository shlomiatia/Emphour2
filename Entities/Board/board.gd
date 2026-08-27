class_name Board extends Node2D

const PLAYER_ROW := 1
const ENEMY_ROW := 0

@export var slot_scene: PackedScene
@export_range(1, 5) var slot_count := 3:
    set(value):
        slot_count = value
        if is_node_ready():
            rebuild_slots()
@export var row_spacing := 8.0
@export var slot_spacing := 195.0

var dragged_card: Card
var highlighted_target: CardSlot
var slots: Array[CardSlot]

signal target_chosen(slot: CardSlot)
signal state_changed

func _ready() -> void:
    rebuild_slots()

func _process(_delta: float) -> void:
    var target := get_overlap_target(dragged_card) if dragged_card else get_target_at(get_viewport().get_mouse_position())
    if target == highlighted_target:
        return
    if highlighted_target:
        highlighted_target.set_hovering(false)
    highlighted_target = target
    if highlighted_target:
        highlighted_target.set_hovering(true)

func _unhandled_input(event: InputEvent) -> void:
    if !(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed):
        return
    var target := get_target_at(event.position)
    if target:
        target_chosen.emit(target)
        get_viewport().set_input_as_handled()

func rebuild_slots() -> void:
    var rows := $Rows.get_children()
    var row_height := get_row_height()
    clear_slots(rows)
    for row_index in rows.size():
        var row := rows[row_index] as Node2D
        row.position.y = (row_index - (rows.size() - 1) / 2.0) * row_height
        for column in slot_count:
            var slot := slot_scene.instantiate() as CardSlot
            slot.row = row_index
            slot.column = column
            slot.position.x = (column - (slot_count - 1) / 2.0) * slot_spacing
            row.add_child(slot)
            slots.append(slot)
    refresh_rows()

func clear_slots(rows: Array[Node]) -> void:
    slots.clear()
    for row in rows:
        for slot in row.get_children():
            slot.free()

func refresh_rows() -> void:
    for slot in slots:
        slot.set_active(slot.row == PLAYER_ROW, slot.row == ENEMY_ROW)

func get_row_height() -> float:
    return Card.SIZE.y + row_spacing

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

func replace_random(card: Card, side: int) -> Card:
    var slot := get_row_slots(get_side_row(side)).pick_random() as CardSlot
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
    state_changed.emit()

func enable_player_targets(full_row: bool) -> void:
    clear_targets()
    for slot in get_row_slots(PLAYER_ROW):
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
    if highlighted_target:
        highlighted_target.set_hovering(false)
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

func notify_state_changed() -> void:
    state_changed.emit()

func get_side_row(side: int) -> int:
    return PLAYER_ROW if side == GameRules.Side.PLAYER else ENEMY_ROW

func get_row_slots(row: int) -> Array[CardSlot]:
    return get_slots().filter(func(slot: CardSlot) -> bool: return slot.row == row && slot.visible)

func get_slots() -> Array[CardSlot]:
    return slots

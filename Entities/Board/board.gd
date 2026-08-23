class_name Board extends Node2D

const ROW_COUNT := 4

@export var player_row := 2
@export var enemy_row := 1
@onready var movement: FrontMovement = $FrontMovement

func _ready() -> void:
    movement.setup(self)
    refresh_rows()

func refresh_rows() -> void:
    for slot in get_slots():
        slot.set_active(slot.row == player_row, slot.row == enemy_row)

func play_leftmost(card: Card, side: int) -> bool:
    for slot in get_row_slots(get_side_row(side)):
        if !slot.get_card():
            slot.place(card)
            return true
    return false

func replace_at(card: Card, point: Vector2, side: int) -> Card:
    var slot := get_slot_at(point, get_side_row(side))
    if !slot || !slot.get_card():
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

func contains_row_point(point: Vector2, side: int) -> bool:
    return get_slot_at(point, get_side_row(side)) != null

func get_cards(side: int) -> Array[Card]:
    var result: Array[Card]
    for slot in get_row_slots(get_side_row(side)):
        if slot.get_card():
            result.append(slot.get_card())
    return result

func reveal_enemy_cards() -> void:
    for card in get_cards(GameRules.Side.ENEMY):
        card.set_hidden(false)

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

func get_slot_at(point: Vector2, row: int) -> CardSlot:
    for slot in get_row_slots(row):
        if slot.contains_point(point):
            return slot
    return null

func get_row_slots(row: int) -> Array[CardSlot]:
    return get_slots().filter(func(slot: CardSlot) -> bool: return slot.row == row)

func get_slots() -> Array[CardSlot]:
    var result: Array[CardSlot]
    for row in $Rows.get_children():
        for slot in row.get_children():
            result.append(slot)
    return result

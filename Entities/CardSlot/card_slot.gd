class_name CardSlot extends Node2D

@export var row := 0
@export var column := 0
@export var slot_size := Vector2(182, 253)
@onready var border: NinePatchRect = $Border
@onready var anchor: Node2D = $CardAnchor

var row_color := Color(0.1, 0.08, 0.15, 0.25)
var targetable := false
var hovering := false

func _ready() -> void:
    border.position = -slot_size / 2.0
    border.size = slot_size

func _process(delta: float) -> void:
    var card := get_card()
    if card:
        move_card(card, delta)

func move_card(card: Card, delta: float) -> void:
    if card.moving:
        return
    CardMotion.approach(card, Vector2.ZERO, Vector2.ONE, 0.0, delta)
    if !card.attacking:
        card.z_index = 2

func place(card: Card) -> void:
    var from_enemy_hand := card.get_parent() is CardHand && card.face_down
    card.reparent(anchor)
    card.draggable = false
    card.hover_enabled = false
    card.set_hovering(false)
    if from_enemy_hand:
        card.move_to_line(global_position)

func get_card() -> Card:
    for child in anchor.get_children():
        if child is Card:
            return child
    return null

func set_active(player_active: bool, enemy_active: bool) -> void:
    if player_active:
        row_color = Color(0.2, 0.7, 1.0, 0.78)
    elif enemy_active:
        row_color = Color(1.0, 0.3, 0.25, 0.78)
    else:
        row_color = Color(0.1, 0.08, 0.15, 0.25)
    refresh_border()

func set_targetable(value: bool) -> void:
    targetable = value
    refresh_border()

func set_hovering(value: bool) -> void:
    hovering = value
    refresh_border()

func refresh_border() -> void:
    border.self_modulate = Color.WHITE if targetable && hovering else row_color
    border.modulate = Card.HIGHLIGHT_COLOR if targetable && hovering else Color.WHITE
    var card := get_card()
    if card:
        card.set_highlighted(targetable && hovering)

func contains_point(point: Vector2) -> bool:
    return Rect2(-slot_size / 2.0, slot_size).has_point(to_local(point))

func get_global_rect() -> Rect2:
    return Rect2(global_position - slot_size / 2.0, slot_size)

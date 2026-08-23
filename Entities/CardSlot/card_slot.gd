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
    var weight := minf(delta * 10.0, 1.0)
    card.position = card.position.lerp(Vector2.ZERO, weight)
    card.rotation = lerp_angle(card.rotation, 0.0, weight)
    card.z_index = 2

func place(card: Card) -> void:
    card.reparent(anchor)
    card.draggable = false
    card.hover_enabled = false
    card.set_hovering(false)
    card.set_selectable(false)

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
    border.modulate = Color("#fee761") if targetable && hovering else Color.WHITE

func contains_point(point: Vector2) -> bool:
    return Rect2(-slot_size / 2.0, slot_size).has_point(to_local(point))

func get_global_rect() -> Rect2:
    return Rect2(global_position - slot_size / 2.0, slot_size)

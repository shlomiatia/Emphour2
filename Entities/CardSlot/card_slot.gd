class_name CardSlot extends Node2D

@export var row := 0
@export var column := 0
@onready var border: NinePatchRect = $Border
@onready var anchor: Node2D = $CardAnchor

func place(card: Card) -> void:
    card.reparent(anchor)
    card.position = Vector2.ZERO
    card.rotation = 0.0
    card.scale = Card.BOARD_SCALE
    card.draggable = false
    card.z_index = 2

func get_card() -> Card:
    for child in anchor.get_children():
        if child is Card:
            return child
    return null

func contains_point(point: Vector2) -> bool:
    return Rect2(-60, -76, 120, 152).has_point(to_local(point))

func set_active(player_active: bool, enemy_active: bool) -> void:
    if player_active:
        border.self_modulate = Color(0.2, 0.7, 1.0, 0.78)
    elif enemy_active:
        border.self_modulate = Color(1.0, 0.3, 0.25, 0.78)
    else:
        border.self_modulate = Color(0.1, 0.08, 0.15, 0.25)

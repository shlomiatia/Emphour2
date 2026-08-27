class_name CardHand extends Node2D

@export var side: int = GameRules.Side.PLAYER
@export var face_down := false
@export var card_spacing := 112.0
@export var angle_step_degrees := 2.5
@export var arc_direction := 1.0
@export var hover_enabled := true
@export var hover_offset := Vector2(0, -52)
@onready var interaction: HandInteraction = $Interaction

signal card_clicked(card: Card)
signal card_released(card: Card)
signal card_cancelled

func _ready() -> void:
    interaction.setup(self)

func _process(delta: float) -> void:
    arrange_cards(delta)

func arrange_cards(delta: float) -> void:
    var cards := get_cards()
    for index in cards.size():
        move_card(cards[index], get_card_props(index, cards.size()), delta, index)

func move_card(card: Card, props: Dictionary, delta: float, index: int) -> void:
    if card.dragging || card.moving:
        return
    var hovered := card.hovering && card.hover_enabled
    var target_position: Vector2 = props["position"] + (hover_offset if hovered else Vector2.ZERO)
    var weight := minf(delta * 10.0, 1.0)
    card.position = card.position.lerp(target_position, weight)
    card.scale = card.scale.lerp(Vector2.ONE * (0.25 if face_down else 1.0), weight)
    card.rotation = lerp_angle(card.rotation, 0.0 if hovered else float(props["rotation"]), weight)
    card.z_index = 100 if hovered else index + 5

func get_card_props(index: int, count: int) -> Dictionary:
    var angle := deg_to_rad((float(index) - float(count - 1) / 2.0) * angle_step_degrees)
    var radius := card_spacing / sin(deg_to_rad(angle_step_degrees))
    var position := Vector2(radius * sin(angle), (-radius * cos(angle) + radius) * arc_direction)
    return {"position": position, "rotation": angle * arc_direction}

func add_card(card: Card) -> void:
    if card.get_parent():
        card.reparent(self)
    else:
        add_child(card)
    card.set_side(side)
    card.set_hidden(face_down)
    card.scale = Vector2.ONE * (0.25 if face_down else 1.0)
    card.hover_enabled = hover_enabled

func get_card_at(point: Vector2) -> Card:
    var cards := get_cards()
    cards.reverse()
    for card in cards:
        if card.contains_point(point):
            return card
    return null

func get_card_count() -> int:
    return get_cards().size()

func set_draggable(value: bool) -> void:
    if !value:
        interaction.stop()
    for card in get_cards():
        card.draggable = value

func get_cards() -> Array[Card]:
    var result: Array[Card]
    for child in get_children():
        if child is Card:
            result.append(child)
    return result

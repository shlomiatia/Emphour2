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

func add_drawn_card(card: Card, source: Node2D) -> void:
    add_card(card)
    card.position = to_local(source.global_position)
    card.scale = Vector2.ONE * 0.18
    card.rotation = 0.0
    card.z_index = get_card_count() + 100
    card.moving = true
    var props := get_card_props(get_card_count() - 1, get_card_count())
    var target_scale := Vector2.ONE * (0.25 if face_down else 1.0)
    var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    tween.tween_property(card, "position", props["position"], 0.45)
    tween.parallel().tween_property(card, "scale", target_scale, 0.45)
    tween.parallel().tween_property(card, "rotation", props["rotation"], 0.45)
    tween.tween_callback(finish_draw.bind(card))

func finish_draw(card: Card) -> void:
    card.finish_move()
    card.z_index = get_cards().find(card) + 5

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

class_name CardTooltip extends CanvasLayer

const HOVER_DELAY := 0.45

@onready var panel: Panel = $Panel
@onready var description: Label = $Panel/Description

var hovered_card: Card
var hover_started := 0

func _process(_delta: float) -> void:
    var card := get_hovered_card(get_viewport().get_mouse_position())
    if card != hovered_card:
        hovered_card = card
        hover_started = Time.get_ticks_msec()
        panel.hide()
    elif hovered_card && !panel.visible && Time.get_ticks_msec() - hover_started >= HOVER_DELAY * 1000:
        show_tooltip()

func get_hovered_card(point: Vector2) -> Card:
    var result: Card
    for node in get_tree().get_nodes_in_group("cards"):
        var card := node as Card
        if card && !card.face_down && !card.dragging && card.contains_point(point) && (!result || card.z_index >= result.z_index):
            result = card
    return result

func show_tooltip() -> void:
    description.text = get_description(hovered_card.data)
    description.size = description.get_combined_minimum_size()
    panel.size = description.size + Vector2(28, 24)
    position_tooltip(get_viewport().get_mouse_position())
    panel.show()

func position_tooltip(mouse_position: Vector2) -> void:
    var viewport_size := get_viewport().get_visible_rect().size
    var position := mouse_position + Vector2(18, 18)
    position.x = minf(position.x, viewport_size.x - panel.size.x)
    position.y = minf(position.y, viewport_size.y - panel.size.y)
    panel.position = position.max(Vector2.ZERO)

func get_description(data: CardData) -> String:
    var lines: Array[String]
    if data.strength:
        lines.append("Strength: %s" % data.strength)
    if data.attack:
        lines.append("%s attack" % get_attack_name(data.attack_type))
    if data.anti_attack != CardData.AttackType.NONE:
        lines.append("Block 1 %s attack" % get_attack_name(data.anti_attack))
    return "\n".join(lines)

func get_attack_name(type: CardData.AttackType) -> String:
    return CardData.AttackType.keys()[type].capitalize()

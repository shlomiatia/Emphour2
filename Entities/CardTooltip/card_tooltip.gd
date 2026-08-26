class_name CardTooltip extends CanvasLayer

const HOVER_DELAY := 0.45
const PREVIEW_SCALE := 0.42
const PREVIEW_COLUMNS := 3
const PREVIEW_WIDTH := 116

@onready var panel: Panel = $Panel
@onready var description: Label = $Panel/Description
@onready var cards: Node2D = $Panel/Cards

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
        if card && !card.get_meta("tooltip_preview", false) && can_show_for(card) && card.contains_point(point) && (!result || card.z_index >= result.z_index):
            result = card
    return result

func show_tooltip() -> void:
    if is_hidden_enemy_card(hovered_card):
        show_enemy_cards()
        return
    description.text = get_description(hovered_card.data)
    description.size = description.get_combined_minimum_size()
    panel.size = description.size + Vector2(28, 24)
    position_tooltip(get_viewport().get_mouse_position())
    panel.show()

func can_show_for(card: Card) -> bool:
    return !card.dragging && (!card.face_down || is_hidden_enemy_card(card) && !is_dragging())

func is_hidden_enemy_card(card: Card) -> bool:
    var game := get_parent() as CardBattle
    return game && card.face_down && game.board.get_cards(GameRules.Side.ENEMY).has(card)

func is_dragging() -> bool:
    var game := get_parent() as CardBattle
    return game && game.player_hand.interaction.dragging_card != null

func show_enemy_cards() -> void:
    clear_cards()
    var source := get_possible_cards_source()
    var possible := get_possible_cards(source)
    for index in possible.size():
        add_preview(possible[index], index, get_card_count(source, possible[index].card_name))
    var columns := mini(possible.size(), PREVIEW_COLUMNS)
    var rows := ceili(float(possible.size()) / PREVIEW_COLUMNS)
    description.hide()
    panel.size = Vector2(columns * PREVIEW_WIDTH + 20, rows * 126 + 20)
    position_tooltip(get_viewport().get_mouse_position())
    panel.show()

func get_possible_cards(source: Array[Card]) -> Array[Card]:
    var result: Array[Card]
    for card in source:
        if !result.any(func(item: Card) -> bool: return item.card_name == card.card_name):
            result.append(card)
    return result

func get_card_count(source: Array[Card], card_name: String) -> int:
    var count := 0
    for card in source:
        if card.card_name == card_name:
            count += 1
    return count

func get_possible_cards_source() -> Array[Card]:
    var result: Array[Card]
    var game := get_parent() as CardBattle
    result.assign(game.enemy_hand.get_cards())
    result.append(hovered_card)
    return result

func add_preview(source: Card, index: int, count: int) -> void:
    var game := get_parent() as CardBattle
    var card := game.create_card(source.card_name, source.side)
    cards.add_child(card)
    card.set_meta("tooltip_preview", true)
    card.set_preview_count(count)
    card.count.add_theme_color_override("font_color", Color("#180f24"))
    card.scale = Vector2.ONE * PREVIEW_SCALE
    card.position = Vector2(54 + index % PREVIEW_COLUMNS * PREVIEW_WIDTH, 69 + index / PREVIEW_COLUMNS * 126)

func clear_cards() -> void:
    for card in cards.get_children():
        card.queue_free()

func position_tooltip(mouse_position: Vector2) -> void:
    var viewport_size := get_viewport().get_visible_rect().size
    var position := mouse_position + Vector2(18, 18)
    position.x = minf(position.x, viewport_size.x - panel.size.x)
    position.y = minf(position.y, viewport_size.y - panel.size.y)
    panel.position = position.max(Vector2.ZERO)

func get_description(data: CardData) -> String:
    description.show()
    clear_cards()
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

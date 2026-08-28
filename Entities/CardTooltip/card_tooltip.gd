class_name CardTooltip extends CanvasLayer

const HOVER_DELAY := 0.45

@onready var data_tooltip: CardDataTooltip = $CardDataTooltip
@onready var enemy_tooltip: EnemyCardsTooltip = $EnemyCardsTooltip

var hovered_card: Card
var hover_started := 0

func _process(_delta: float) -> void:
    var card := get_hovered_card(get_viewport().get_mouse_position())
    if card != hovered_card:
        hovered_card = card
        hover_started = Time.get_ticks_msec()
        hide_tooltips()
    elif hovered_card && !has_visible_tooltip() && Time.get_ticks_msec() - hover_started >= HOVER_DELAY * 1000:
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
        enemy_tooltip.show_cards(get_possible_card_names(), hovered_card.side)
        position_tooltip(enemy_tooltip)
        return
    data_tooltip.show_data(hovered_card.data)
    position_tooltip(data_tooltip)

func can_show_for(card: Card) -> bool:
    return !card.dragging && (!card.face_down || is_hidden_enemy_card(card) && !is_dragging())

func is_hidden_enemy_card(card: Card) -> bool:
    var game := get_parent() as CardBattle
    return game && card.face_down && game.board.get_cards(GameRules.Side.ENEMY).has(card)

func is_dragging() -> bool:
    var game := get_parent() as CardBattle
    return game && game.player_hand.interaction.dragging_card != null

func get_possible_card_names() -> Array[String]:
    var game := get_parent() as CardBattle
    var result: Array[String]
    for card in game.enemy_hand.get_cards() + game.board.get_cards(GameRules.Side.ENEMY):
        if card.face_down:
            result.append(card.card_name)
    return result

func position_tooltip(panel: Control) -> void:
    var viewport_size := get_viewport().get_visible_rect().size
    var target := get_viewport().get_mouse_position() + Vector2(18, 18)
    target.x = minf(target.x, viewport_size.x - panel.size.x)
    target.y = minf(target.y, viewport_size.y - panel.size.y)
    panel.position = target.max(Vector2.ZERO)

func hide_tooltips() -> void:
    data_tooltip.hide()
    enemy_tooltip.hide()

func has_visible_tooltip() -> bool:
    return data_tooltip.visible || enemy_tooltip.visible

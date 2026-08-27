class_name EnemyCardsTooltip extends Panel

const PREVIEW_SCALE := 0.42
const PREVIEW_COLUMNS := 3
const PREVIEW_WIDTH := 116

@onready var cards: Node2D = $Cards

func show_cards(card_names: Array[String], side: int) -> void:
    clear_cards()
    var counts := get_counts(card_names)
    var names := counts.keys()
    for index in names.size():
        var card_name := names[index] as String
        add_preview(card_name, side, index, counts[card_name])
    var columns := mini(names.size(), PREVIEW_COLUMNS)
    var rows := ceili(float(names.size()) / PREVIEW_COLUMNS)
    size = Vector2(columns * PREVIEW_WIDTH + 20, rows * 126 + 20)
    show()

func get_counts(card_names: Array[String]) -> Dictionary:
    var result := {}
    for card_name in card_names:
        result[card_name] = result.get(card_name, 0) + 1
    return result

func add_preview(card_name: String, side: int, index: int, count: int) -> void:
    var card := CardFactory.create(card_name, side)
    cards.add_child(card)
    card.set_meta("tooltip_preview", true)
    card.set_preview_count(count)
    card.count.add_theme_color_override("font_color", Color("#180f24"))
    card.scale = Vector2.ONE * PREVIEW_SCALE
    card.position = Vector2(54 + index % PREVIEW_COLUMNS * PREVIEW_WIDTH, 69 + index / PREVIEW_COLUMNS * 126)

func clear_cards() -> void:
    for card in cards.get_children():
        cards.remove_child(card)
        card.queue_free()

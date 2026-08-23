extends SceneTree

var game: CardGame

func _initialize() -> void:
    run_test()

func run_test() -> void:
    game = load("res://Scenes/Main.tscn").instantiate()
    root.add_child(game)
    for _frame in 10:
        await process_frame
    var tooltip := game.get_node("CardTooltip") as CardTooltip
    var card := game.player_hand.get_cards()[0]
    assert(tooltip.get_hovered_card(card.global_position) != null)
    tooltip.hovered_card = card
    tooltip.show_tooltip()
    assert(tooltip.panel.visible)
    assert(!tooltip.description.text.is_empty())
    quit()

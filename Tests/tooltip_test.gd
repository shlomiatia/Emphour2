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
    assert(tooltip.get_hovered_card(game.enemy_hand.get_cards()[0].global_position) == null)
    tooltip.hovered_card = game.board.get_cards(GameRules.Side.ENEMY)[0]
    tooltip.show_tooltip()
    assert(!tooltip.description.visible)
    assert(tooltip.cards.get_child_count() == 2)
    assert((tooltip.cards.get_child(0) as Card).count.text == "x2")
    assert((tooltip.cards.get_child(1) as Card).count.text == "x1")
    quit()

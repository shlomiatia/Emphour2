extends SceneTree

var game: CardBattle

func _initialize() -> void:
    run_test()

func run_test() -> void:
    game = load("res://Scenes/Battle/Battle.tscn").instantiate()
    root.add_child(game)
    for _frame in 10:
        await process_frame
    var tooltip := game.get_node("CardTooltip") as CardTooltip
    var card := game.player_hand.get_cards()[0]
    assert(tooltip.get_hovered_card(card.global_position) != null)
    tooltip.hovered_card = card
    tooltip.show_tooltip()
    assert(tooltip.data_tooltip.visible)
    assert(!tooltip.data_tooltip.description.text.is_empty())
    assert(tooltip.get_hovered_card(game.enemy_hand.get_cards()[0].global_position) == null)
    tooltip.hovered_card = game.board.get_cards(GameRules.Side.ENEMY)[0]
    tooltip.show_tooltip()
    assert(tooltip.enemy_tooltip.visible)
    assert(tooltip.enemy_tooltip.cards.get_child_count() == 2)
    var counts := {}
    for preview in tooltip.enemy_tooltip.cards.get_children():
        counts[preview.card_name] = preview.count.text
    assert(counts["Militia"] == "x2")
    assert(counts["Archer"] == "x1")
    quit()

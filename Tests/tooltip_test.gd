extends SceneTree

var game: CardBattle

func _initialize() -> void:
    run_test()

func run_test() -> void:
    game = load("res://Scenes/Battlefield/Battlefield.tscn").instantiate()
    root.add_child(game)
    await game.battle_ready
    var tooltip := game.get_node("CardTooltip") as CardTooltip
    var card := game.player_hand.get_cards()[0]
    assert(tooltip.get_hovered_card(card.global_position) != null)
    tooltip.hovered_card = card
    tooltip.show_tooltip()
    assert(tooltip.data_tooltip.visible)
    assert(!tooltip.data_tooltip.description.text.is_empty())
    var armored := CardCatalog.get_data("Foot Knight")
    assert(tooltip.data_tooltip.get_description(armored).contains("Block 1 non armor piercing attack"))
    var cavalry := CardCatalog.get_data("Light Cavalry")
    assert(tooltip.data_tooltip.get_description(cavalry).contains("Charge attack"))
    var crossbowman := game.create_card("Crossbowman", GameRules.Side.PLAYER)
    game.add_child(crossbowman)
    await process_frame
    assert(crossbowman.attack_icon.texture == load("res://Textures/Armor.png"))
    assert(crossbowman.attack_counter.visible)
    crossbowman.queue_free()
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

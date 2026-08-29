extends SceneTree

var game: CardBattle

func _initialize() -> void:
    run_test()

func run_test() -> void:
    CampaignState.start_in_act_2 = false
    CampaignState.reset()
    CampaignState.selected_city = CampaignState.act_1_city_id(1)
    game = load("res://Scenes/Battlefield/Battlefield.tscn").instantiate()
    root.add_child(game)
    await game.battle_ready
    await process_frame
    assert(game.tutorial.active)
    assert(game.tutorial.message.text.text == "General, let's teach you how to fight")
    game.tutorial.message.advance()
    await process_frame
    assert(game.tutorial.message.text.text == "Our opponent played a card in secret.")
    assert(hand_has("Militia"))
    assert(hand_has("Archer"))
    assert(hand_has("Stakes"))
    assert(game.player_hand.get_cards().slice(0, 3).map(func(card: Card) -> String: return card.card_name) == ["Militia", "Stakes", "Archer"])
    var last_card: Card
    while !game.player_draw_pile.is_empty():
        last_card = game.draw_card(GameRules.Side.PLAYER)
    assert(last_card.card_name == "Mantlet")
    assert(game.board.get_cards(GameRules.Side.ENEMY)[0].card_name == "Light Cavalry")
    quit()

func hand_has(card_name: String) -> bool:
    return game.player_hand.get_cards().any(func(card: Card) -> bool: return card.card_name == card_name)

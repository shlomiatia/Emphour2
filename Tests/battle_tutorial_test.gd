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
    assert(game.tutorial.active)
    assert(hand_has("Militia"))
    assert(hand_has("Archer"))
    assert(hand_has("Stakes"))
    assert(game.board.get_cards(GameRules.Side.ENEMY)[0].card_name == "Light Cavalry")
    quit()

func hand_has(card_name: String) -> bool:
    return game.player_hand.get_cards().any(func(card: Card) -> bool: return card.card_name == card_name)

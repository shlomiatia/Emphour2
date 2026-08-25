extends SceneTree

func _initialize() -> void:
    run_test()

func run_test() -> void:
    Engine.time_scale = 30.0
    var game := load("res://Scenes/Game/Game.tscn").instantiate() as CardGame
    root.add_child(game)
    await process_frame
    verify_strength_difference(game)
    verify_defence_consumption(game)
    verify_loss_prediction(game)
    verify_final_winners(game)
    await verify_score_victory(game)
    game.free()
    quit()

func verify_strength_difference(game: CardGame) -> void:
    var militia := game.player_hand.get_cards().filter(func(card: Card) -> bool: return card.card_name == "Militia")[0] as Card
    game.board.play_leftmost(militia, GameRules.Side.PLAYER)
    assert(game.battle.strength_difference() == 1)

func verify_defence_consumption(game: CardGame) -> void:
    var archer := game.player_hand.get_cards().filter(func(card: Card) -> bool: return card.card_name == "Archer")[0] as Card
    var mantlet := game.player_hand.get_cards().filter(func(card: Card) -> bool: return card.card_name == "Mantlet")[0] as Card
    assert(game.battle.available_targets(archer, [mantlet], [mantlet], []) == [mantlet])

func verify_loss_prediction(game: CardGame) -> void:
    var attackers: Array[Card] = [create_rule_card("Archer"), create_rule_card("Archer"), create_rule_card("Light Cavalry")]
    var defenders: Array[Card] = [create_rule_card("Stakes"), create_rule_card("Stakes"), create_rule_card("Stakes")]
    var lone_defender := create_rule_card("Militia")
    assert(game.battle.potential_losses(attackers, defenders) == 2)
    assert(game.battle.potential_losses(attackers, [lone_defender]) == 1)
    for card in attackers + defenders:
        card.free()
    lone_defender.free()

func create_rule_card(card_name: String) -> Card:
    var card := Card.new()
    card.data = CardCatalog.get_data(card_name)
    return card

func verify_final_winners(game: CardGame) -> void:
    game.battle_state.active = true
    game.battle_state.balance = -1
    assert(game.battle_state.balance_winner() == GameRules.Side.ENEMY)
    game.battle_state.balance = 0
    assert(game.battle_state.balance_winner() == -1)

func verify_score_victory(game: CardGame) -> void:
    game.battle_state.balance = 4
    await game.battle_state.finish(1, false)
    assert(game.battle_state.balance == 5)
    assert(game.finished)
    assert(game.result_label.text == "PLAYER VICTORY")
    assert(game.battle_hud.balance_label.text.ends_with("+5"))

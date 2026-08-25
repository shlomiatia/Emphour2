extends SceneTree

func _initialize() -> void:
    run_test()

func run_test() -> void:
    Engine.time_scale = 30.0
    var game := load("res://Scenes/Battle/Battle.tscn").instantiate() as CardBattle
    root.add_child(game)
    await process_frame
    verify_strength_difference(game)
    verify_hud(game)
    verify_defence_consumption(game)
    verify_loss_prediction(game)
    verify_enemy_deck_generation()
    verify_loyalty_rules()
    await verify_pre_casualty_balance(game)
    verify_final_winners(game)
    await verify_score_victory(game)
    game.free()
    quit()

func verify_strength_difference(game: CardBattle) -> void:
    var militia := game.player_hand.get_cards().filter(func(card: Card) -> bool: return card.card_name == "Militia")[0] as Card
    game.board.play_leftmost(militia, GameRules.Side.PLAYER)
    assert(game.battle.strength_difference() == 1)

func verify_hud(game: CardBattle) -> void:
    game.battle.update_preview()
    assert(!game.battle_hud.enemy_stats.text.contains("Strength"))
    assert(game.battle_hud.get_node("BalanceLabel").text == "BALANCE OF POWER")
    assert(game.battle_hud.preview.position.x > game.battle_hud.marker.position.x)

func verify_defence_consumption(game: CardBattle) -> void:
    var archer := game.player_hand.get_cards().filter(func(card: Card) -> bool: return card.card_name == "Archer")[0] as Card
    var mantlet := game.player_hand.get_cards().filter(func(card: Card) -> bool: return card.card_name == "Mantlet")[0] as Card
    assert(game.battle.available_targets(archer, [mantlet], [mantlet], []) == [mantlet])

func verify_loss_prediction(game: CardBattle) -> void:
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

func verify_enemy_deck_generation() -> void:
    var deck := EnemyDeck.generate(8, 20, CardCatalog.CARDS)
    var value: int = deck.reduce(func(sum: int, card: String) -> int: return sum + CardCatalog.get_value(card), 0)
    assert(deck.size() == 8)
    assert(value == 20)

func verify_loyalty_rules() -> void:
    assert(LoyaltyRules.CHANCES[-1] == [10, 0, 0])
    assert(LoyaltyRules.CHANCES[-5] == [30, 20, 15])
    assert(RewardRules.belongs_to("Militia", "Peasants"))
    assert(RewardRules.belongs_to("Knight", "Nobility"))

func verify_pre_casualty_balance(game: CardBattle) -> void:
    var difference := game.battle.strength_difference()
    game.battle_state.active = true
    await game.battle_state.move_balance(difference)
    await game.battle.resolve()
    assert(difference == 1)
    assert(game.battle.strength_difference() == 0)
    assert(game.battle_state.balance == 1)

func verify_final_winners(game: CardBattle) -> void:
    game.battle_state.active = true
    game.battle_state.balance = -1
    assert(game.battle_state.balance_winner() == GameRules.Side.ENEMY)
    game.battle_state.balance = 0
    assert(game.battle_state.balance_winner() == -1)

func verify_score_victory(game: CardBattle) -> void:
    game.battle_state.balance = 4
    await game.battle_state.move_balance(1)
    await game.battle_state.finish(false)
    assert(game.battle_state.balance == 5)
    assert(game.finished)
    assert(game.result_label.text == "PLAYER VICTORY")
    assert(is_equal_approx(game.battle_hud.marker.position.x, game.battle_hud.meter_position(5, game.battle_hud.marker)))

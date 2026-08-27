extends SceneTree

func _initialize() -> void:
    run_test()

func run_test() -> void:
    Engine.time_scale = 30.0
    var game := load("res://Scenes/Battle/Battle.tscn").instantiate() as CardBattle
    root.add_child(game)
    await game.battle_ready
    verify_strength_difference(game)
    verify_hud(game)
    verify_defence_consumption(game)
    verify_loss_prediction(game)
    verify_enemy_deck_generation()
    verify_loyalty_rules()
    await verify_pre_casualty_balance(game)
    verify_final_winners(game)
    verify_game_over(game)
    verify_retry_state(game)
    await verify_score_victory(game)
    game.free()
    quit()

func verify_strength_difference(game: CardBattle) -> void:
    var before := game.battle.strength_difference()
    var militia := game.player_hand.get_cards().filter(func(card: Card) -> bool: return card.card_name == "Militia")[0] as Card
    game.board.play_leftmost(militia, GameRules.Side.PLAYER)
    assert(game.battle.strength_difference() == before + 1)

func verify_hud(game: CardBattle) -> void:
    assert(game.board.get_parent() == game.card_space)
    assert(game.player_hand.get_parent() == game.card_space)
    assert(game.card_space.follow_viewport_enabled)
    assert(game.card_space.layer > game.get_node("Interface").layer)
    assert(game.get_node("Overlay").layer > game.card_space.layer)
    assert(game.enemy_hand.get_parent() is CanvasLayer)
    game.battle_hud.set_losses(5, 4)
    assert(game.battle_hud.player_losses.get_child_count() == 5)
    assert(game.battle_hud.enemy_losses.get_child_count() == 4)
    game.battle.update_preview()
    assert(!game.battle_hud.has_node("BalanceLabel"))
    assert(!game.battle_hud.has_node("EnemyShield"))
    assert(game.battle_hud.preview_tween != null)

func verify_defence_consumption(game: CardBattle) -> void:
    var archer := create_rule_card("Archer")
    var mantlet := create_rule_card("Mantlet")
    var militia := create_rule_card("Militia")
    assert(game.battle.available_targets(archer, [mantlet, militia], []) == [militia])
    archer.free()
    mantlet.free()
    militia.free()

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
    var value: float = deck.reduce(func(sum: float, card: String) -> float: return sum + CardCatalog.get_value(card), 0.0)
    assert(deck.size() == 8)
    assert(value == 20.0)
    assert(CardCatalog.get_value("Crossbowman") == 2.0)
    assert(EnemyDeck.generate(1, 2, ["Crossbowman"]) == ["Crossbowman"])
    assert(EnemyDeck.new().build("City 1") == ["Light Cavalry", "Militia", "Militia"])
    assert(!EnemyDeck.get_pool("City 3").has("Crossbowman"))
    assert(EnemyDeck.get_pool("City 4").has("Crossbowman"))
    assert(EnemyDeckPicker.get_tiers(["Militia", "Crossbowman", "Foot Knight", "Knight"]) == [1, 2, 3, 4])
    assert(EnemyDeckPicker.total_weight(["Militia", "Archer", "Mantlet", "Stakes"]) == 10)
    verify_generated_city("City 3")
    verify_generated_city("City 7")
    verify_final_loyalty_decks()
    var late_deck := EnemyDeck.new().build("City 2")
    assert(late_deck.size() == 6)
    assert(late_deck.reduce(func(sum: int, card: String) -> int: return sum + CardCatalog.get_value(card), 0) == 7)

func verify_generated_city(city_name: String) -> void:
    var deck := EnemyDeck.new().build(city_name)
    var rule: Array = EnemyDeck.CITY_RULES[city_name]
    var value: float = deck.reduce(func(sum: float, card: String) -> float: return sum + CardCatalog.get_value(card), 0.0)
    assert(deck.size() == rule[0])
    assert(value == rule[1])

func verify_final_loyalty_decks() -> void:
    var loyalty := CampaignState.loyalty.duplicate()
    CampaignState.loyalty = {"Peasants": 0, "Nobility": -1}
    verify_final_loyalty_deck(9, 24, "Nobility")
    CampaignState.loyalty = {"Peasants": -1, "Nobility": 0}
    verify_final_loyalty_deck(13, 20, "Peasants")
    CampaignState.loyalty = loyalty

func verify_final_loyalty_deck(count: int, value: int, group: String) -> void:
    var deck := EnemyDeck.new().build("City 7")
    assert(deck.size() == count)
    assert(deck.all(func(card: String) -> bool: return RewardRules.belongs_to(card, group)))
    assert(deck.reduce(func(sum: int, card: String) -> int: return sum + CardCatalog.get_value(card), 0) == value)

func verify_loyalty_rules() -> void:
    assert(LoyaltyRules.CHANCES[-1] == [10, 0, 0])
    assert(LoyaltyRules.CHANCES[-5] == [30, 20, 15])
    assert(LoyaltyRules.event_for_roll(LoyaltyRules.CHANCES[-3], 5) == LoyaltyRules.Event.BETRAY)
    assert(LoyaltyRules.event_for_roll(LoyaltyRules.CHANCES[-3], 15) == LoyaltyRules.Event.DESERT)
    assert(LoyaltyRules.event_for_roll(LoyaltyRules.CHANCES[-3], 35) == LoyaltyRules.Event.REFUSE)
    assert(LoyaltyRules.event_for_roll(LoyaltyRules.CHANCES[-3], 36) == -1)
    var check := LoyaltyRules.roll(3)
    assert(check["loyalty"] == 3)
    assert(check["chances"] == [0, 0, 0])
    assert(RewardRules.belongs_to("Militia", "Peasants"))
    assert(RewardRules.belongs_to("Knight", "Nobility"))

func verify_pre_casualty_balance(game: CardBattle) -> void:
    var difference := game.battle.strength_difference()
    game.battle_state.active = true
    await game.battle_state.move_balance(difference)
    await game.battle.resolve()
    assert(game.battle_state.balance == difference)

func verify_final_winners(game: CardBattle) -> void:
    game.battle_state.active = true
    game.battle_state.balance = -1
    assert(game.battle_state.balance_winner() == GameRules.Side.ENEMY)
    game.battle_state.balance = 0
    assert(game.battle_state.balance_winner() == -1)
    assert(game.battle_state.result_text(GameRules.Side.ENEMY).begins_with("Game over"))
    assert(game.battle_state.result_color(GameRules.Side.ENEMY) == BattleHud.ENEMY_COLOR)

func verify_retry_state(game: CardBattle) -> void:
    var deck := game.battle_state.entry_deck.duplicate()
    var loyalty := game.battle_state.entry_loyalty.duplicate()
    CampaignState.player_deck.clear()
    CampaignState.loyalty["Peasants"] = -5
    game.battle_state.restore_entry_state()
    assert(CampaignState.player_deck == deck)
    assert(CampaignState.loyalty == loyalty)

func verify_game_over(game: CardBattle) -> void:
    game.battle_state.finish_game(GameRules.Side.ENEMY)
    assert(game.status_label.text.begins_with("Game over"))
    assert(game.status_label.get_theme_color("font_color") == BattleHud.ENEMY_COLOR)
    assert(game.can_restart)
    game.can_restart = false

func verify_score_victory(game: CardBattle) -> void:
    game.battle_state.balance = 4
    await game.battle_state.move_balance(1)
    await game.battle_state.finish(false)
    assert(game.battle_state.balance == 5)
    assert(game.finished)
    assert(game.status_label.text == "Player wins")
    assert(game.status_label.get_theme_color("font_color") == BattleHud.PLAYER_COLOR)
    assert(is_equal_approx(game.battle_hud.marker.position.x, game.battle_hud.meter_position(5, game.battle_hud.marker)))

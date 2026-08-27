extends SceneTree

var game: CardBattle

func _initialize() -> void:
    run_test()

func run_test() -> void:
    Engine.time_scale = 30.0
    CampaignState.reset()
    game = load("res://Scenes/Battlefield/Battlefield.tscn").instantiate()
    root.add_child(game)
    await game.battle_ready
    game.turns.accepting_action = false
    game.player_hand.set_draggable(false)
    verify_mouse_continue()
    await verify_refusal()
    await verify_desertion()
    await verify_betrayal()
    await verify_tracked_replacement()
    await verify_deck_event()
    await verify_final_checks()
    await verify_casualty_persistence()
    await verify_freed_card_safe()
    quit()

func verify_mouse_continue() -> void:
    var received := [false]
    game.loyalty_events.continued.connect(func() -> void: received[0] = true, CONNECT_ONE_SHOT)
    game.loyalty_events.waiting = true
    var event := InputEventMouseButton.new()
    event.pressed = true
    game.loyalty_events._input(event)
    game.loyalty_events.waiting = false
    assert(received[0])

func verify_refusal() -> void:
    var card := find_card("Archer")
    var deck := CampaignState.player_deck.duplicate()
    var hand_count := game.player_hand.get_card_count()
    var pile_count := game.player_draw_pile.size()
    game.loyalty_events.show_message(card, LoyaltyRules.Event.REFUSE)
    assert(game.loyalty_events.visible)
    assert(game.loyalty_events.message.text.contains("refuses to fight"))
    await game.loyalty_events.execute(card, LoyaltyRules.Event.REFUSE)
    assert(CampaignState.player_deck == deck)
    assert(game.player_hand.get_card_count() == hand_count)
    assert(game.player_draw_pile.size() == pile_count - 1)

func verify_desertion() -> void:
    var card := find_card("Mantlet")
    var card_name := card.card_name
    var old_count := CampaignState.player_deck.count(card_name)
    var hand_count := game.player_hand.get_card_count()
    var group := game.loyalty_events.card_group(card)
    var old_loyalty: int = CampaignState.loyalty[group]
    await game.loyalty_events.execute(card, LoyaltyRules.Event.DESERT)
    assert(CampaignState.player_deck.count(card_name) == old_count - 1)
    assert(CampaignState.loyalty[group] == old_loyalty)
    assert(game.player_hand.get_card_count() == hand_count)

func verify_betrayal() -> void:
    var card := find_card("Stakes")
    var old_count := game.enemy_hand.get_card_count()
    var hand_count := game.player_hand.get_card_count()
    var group := game.loyalty_events.card_group(card)
    var old_loyalty: int = CampaignState.loyalty[group]
    await game.loyalty_events.execute(card, LoyaltyRules.Event.BETRAY)
    assert(card.side == GameRules.Side.ENEMY)
    assert(game.enemy_hand.get_card_count() == old_count + 1)
    assert(CampaignState.loyalty[group] == old_loyalty)
    assert(game.player_hand.get_card_count() == hand_count)

func verify_tracked_replacement() -> void:
    game.loyalty_events.deck_candidates.capture("Peasants")
    var candidate: Dictionary = game.loyalty_events.deck_candidates.pending[-1]
    var expected_name: String = candidate["name"]
    await game.loyalty_events.draw_replacement()
    var card := game.loyalty_events.deck_candidates.get_card(candidate)
    assert(card && card.card_name == expected_name)
    assert(card.get_parent() == game.player_hand)

func verify_deck_event() -> void:
    game.player_draw_pile.assign(["Archer"])
    game.player_deck.set_card_count(1)
    game.loyalty_events.deck_candidates.capture("Peasants")
    var candidate := game.loyalty_events.deck_candidates.get_eligible()[0]
    var hand_count := game.player_hand.get_card_count()
    var discard_count := game.player_discard.card_count
    assert(game.loyalty_events.deck_candidates.remove_from_deck(candidate))
    var card := game.loyalty_events.actions.create_deck_card(candidate["name"])
    await game.loyalty_events.execute(card, LoyaltyRules.Event.REFUSE)
    assert(game.player_hand.get_card_count() == hand_count)
    assert(game.player_discard.card_count == discard_count + 1)
    assert(game.player_draw_pile.is_empty())

func verify_final_checks() -> void:
    await process_frame
    for card in game.player_hand.get_cards():
        card.free()
    game.player_hand.add_card(game.create_card("Light Cavalry", GameRules.Side.PLAYER))
    game.player_hand.add_card(game.create_card("Foot Knight", GameRules.Side.PLAYER))
    game.player_draw_pile.assign(["Horse Archer", "Militia"])
    var old_checks := game.loyalty_events.checks_completed
    await game.loyalty_events.run_final_events()
    assert(game.loyalty_events.checks_completed == old_checks + 3)

func verify_casualty_persistence() -> void:
    var card := find_card("Militia")
    var old_count := CampaignState.player_deck.count(card.card_name)
    await game.defeat_card(card)
    assert(CampaignState.player_deck.count(card.card_name) == old_count)

func verify_freed_card_safe() -> void:
    var cards := game.loyalty_events.eligible_cards("Peasants")
    if cards.is_empty():
        game.player_hand.add_card(game.create_card("Archer", GameRules.Side.PLAYER))
        cards = game.loyalty_events.eligible_cards("Peasants")
    game.loyalty_events.run_event("Peasants", LoyaltyRules.Event.REFUSE)
    assert(game.loyalty_events.waiting)
    for card in cards:
        card.free()
    var event := InputEventMouseButton.new()
    event.pressed = true
    game.loyalty_events._input(event)
    await process_frame
    assert(!game.loyalty_events.waiting)

func find_card(card_name: String) -> Card:
    var cards := game.player_hand.get_cards().filter(func(card: Card) -> bool: return card.card_name == card_name)
    if !cards.is_empty():
        return cards[0]
    var card := game.create_card(card_name, GameRules.Side.PLAYER)
    game.player_hand.add_card(card)
    return card

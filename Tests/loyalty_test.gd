extends SceneTree

var game: CardBattle

func _initialize() -> void:
    run_test()

func run_test() -> void:
    Engine.time_scale = 30.0
    CampaignState.reset()
    game = load("res://Scenes/Battle/Battle.tscn").instantiate()
    root.add_child(game)
    await process_frame
    game.turns.accepting_action = false
    game.player_hand.set_draggable(false)
    verify_mouse_continue()
    await verify_refusal()
    await verify_desertion()
    await verify_betrayal()
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
    game.loyalty_events.show_message(card, LoyaltyRules.Event.REFUSE)
    assert(game.event_panel.visible)
    assert(game.event_message.text.contains("refuses to fight"))
    await game.loyalty_events.execute(card, LoyaltyRules.Event.REFUSE)
    assert(CampaignState.player_deck == deck)

func verify_desertion() -> void:
    var card := find_card("Mantlet")
    var old_count := CampaignState.player_deck.count(card.card_name)
    var group := game.loyalty_events.card_group(card)
    await game.loyalty_events.execute(card, LoyaltyRules.Event.DESERT)
    assert(CampaignState.player_deck.count(card.card_name) == old_count - 1)
    assert(CampaignState.public_loyalty[group] == CampaignState.Relation.NEUTRAL)
    assert(CampaignState.internal_loyalty[group] == CampaignState.Relation.NEUTRAL - 1)

func verify_betrayal() -> void:
    var card := find_card("Stakes")
    var old_count := game.enemy_hand.get_card_count()
    var group := game.loyalty_events.card_group(card)
    var old_loyalty: int = CampaignState.internal_loyalty[group]
    await game.loyalty_events.execute(card, LoyaltyRules.Event.BETRAY)
    assert(card.side == GameRules.Side.ENEMY)
    assert(game.enemy_hand.get_card_count() == old_count + 1)
    assert(CampaignState.internal_loyalty[group] == old_loyalty - 1)

func verify_casualty_persistence() -> void:
    var card := find_card("Militia")
    var old_count := CampaignState.player_deck.count(card.card_name)
    await game.defeat_card(card)
    assert(CampaignState.player_deck.count(card.card_name) == old_count)

func verify_freed_card_safe() -> void:
    var cards := game.loyalty_events.eligible_cards("Peasants")
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

class_name LoyaltyEvents extends Node

signal continued

var game: CardBattle
var waiting := false
var running := false

func setup(card_battle: CardBattle) -> void:
    game = card_battle

func _input(event: InputEvent) -> void:
    if !waiting || !event.is_pressed() || event is InputEventKey && event.echo:
        return
    get_viewport().set_input_as_handled()
    continued.emit()

func run() -> void:
    if running:
        return
    running = true
    if CampaignState.is_final_battle():
        await run_final_events()
    else:
        await run_regular_events()
    running = false
    game.event_panel.hide()

func run_final_events() -> void:
    var group := CampaignState.disloyal_group()
    for card in eligible_cards(group):
        for event in LoyaltyRules.roll(CampaignState.internal_loyalty[group]):
            await run_card_event(card, event)

func run_regular_events() -> void:
    for group in CampaignState.internal_loyalty:
        var loyalty: int = CampaignState.internal_loyalty[group]
        for event in LoyaltyRules.roll(loyalty):
            await run_event(group, event)

func run_event(group: String, event: int) -> void:
    var cards := eligible_cards(group)
    if cards.is_empty():
        return
    var card := cards.pick_random() as Card
    await run_card_event(card, event)

func run_card_event(card: Card, event: int) -> void:
    show_message(card, event)
    await wait_for_input()
    if !is_instance_valid(card):
        return
    await execute(card, event)

func eligible_cards(group: String) -> Array[Card]:
    var result: Array[Card]
    for card in game.player_hand.get_cards():
        if !card.is_queued_for_deletion() && RewardRules.belongs_to(card.card_name, group):
            result.append(card)
    return result

func show_message(card: Card, event: int) -> void:
    var actions := ["refuses to fight", "deserts your army", "betrays you"]
    game.event_message.text = "%s %s.\nPress any key or mouse button" % [card.card_name, actions[event]]
    game.event_panel.show()

func wait_for_input() -> void:
    waiting = true
    await continued
    waiting = false

func execute(card: Card, event: int) -> void:
    card.reparent(game)
    if event == LoyaltyRules.Event.REFUSE:
        await card.move_to(game.player_discard.global_position, false, Vector2.ZERO)
        game.player_discard.add_card(card)
    elif event == LoyaltyRules.Event.DESERT:
        CampaignState.player_deck.erase(card.card_name)
        CampaignState.lose_loyalty(card_group(card))
        await card.move_to(card.global_position + Vector2(0, -400), true)
        card.queue_free()
    else:
        CampaignState.lose_loyalty(card_group(card))
        await card.move_to(game.enemy_hand.global_position, false, Vector2.ONE * 0.25)
        card.side = GameRules.Side.ENEMY
        game.enemy_hand.add_card(card)

func card_group(card: Card) -> String:
    return "Nobility" if RewardRules.belongs_to(card.card_name, "Nobility") else "Peasants"

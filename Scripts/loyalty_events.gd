class_name LoyaltyEvents extends Node

signal continued

var game: CardBattle
var waiting := false

func setup(card_battle: CardBattle) -> void:
    game = card_battle

func _input(event: InputEvent) -> void:
    if !waiting || !event.is_pressed() || event is InputEventKey && event.echo:
        return
    continued.emit()
    get_viewport().set_input_as_handled()

func run() -> void:
    for group in CampaignState.loyalty:
        for event in LoyaltyRules.roll(CampaignState.loyalty[group]):
            await run_event(group, event)
    game.event_panel.hide()

func run_event(group: String, event: int) -> void:
    var cards := eligible_cards(group)
    if cards.is_empty():
        return
    var card := cards.pick_random() as Card
    show_message(card, event)
    await wait_for_input()
    await execute(card, event)

func eligible_cards(group: String) -> Array[Card]:
    var result: Array[Card]
    for card in game.player_hand.get_cards():
        if RewardRules.belongs_to(card.card_name, group):
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
        await card.move_to(game.player_discard.global_position)
        game.player_discard.add_card(card)
    elif event == LoyaltyRules.Event.DESERT:
        CampaignState.player_deck.erase(card.card_name)
        await card.move_to(card.global_position + Vector2(0, -400), true)
        card.queue_free()
    else:
        await card.move_to(game.enemy_hand.global_position)
        card.side = GameRules.Side.ENEMY
        game.enemy_hand.add_card(card)

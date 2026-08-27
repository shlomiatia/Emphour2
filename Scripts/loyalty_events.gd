class_name LoyaltyEvents extends Panel

signal continued

@onready var message: Label = $Message

var game: CardBattle
var actions := LoyaltyEventActions.new()
var deck_candidates := LoyaltyDeckCandidates.new()
var waiting := false
var running := false
var checks_completed := 0

func setup(card_battle: CardBattle) -> void:
    game = card_battle
    actions.setup(game)
    deck_candidates.setup(game)

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
    hide()

func run_final_events() -> void:
    var group := CampaignState.disloyal_group()
    deck_candidates.capture(group)
    for card in eligible_cards(group):
        await check_card(card, group)
    for candidate in deck_candidates.get_eligible():
        await check_candidate(candidate, group)

func run_regular_events() -> void:
    for group in CampaignState.internal_loyalty:
        var cards := eligible_cards(group)
        if !cards.is_empty():
            await check_card(cards.pick_random(), group)

func check_card(card: Card, group: String) -> void:
    if !is_instance_valid(card):
        return
    var result := LoyaltyRules.roll(CampaignState.internal_loyalty[group])
    log_check(result, card.card_name)
    if result["event"] != -1:
        await run_card_event(card, result["event"], true)

func check_candidate(candidate: Dictionary, group: String) -> void:
    var result := LoyaltyRules.roll(CampaignState.internal_loyalty[group])
    log_check(result, candidate["name"])
    if result["event"] == -1:
        return
    await run_candidate_event(candidate, result["event"])

func run_candidate_event(candidate: Dictionary, event: int) -> void:
    var card := deck_candidates.get_card(candidate)
    var from_hand := card != null
    if !from_hand && deck_candidates.remove_from_deck(candidate):
        card = actions.create_deck_card(candidate["name"])
    if card:
        await run_card_event(card, event, from_hand)

func run_event(group: String, event: int) -> void:
    var cards := eligible_cards(group)
    if !cards.is_empty():
        await run_card_event(cards.pick_random(), event, true)

func run_card_event(card: Card, event: int, from_hand := true) -> void:
    show_message(card, event)
    await wait_for_input()
    if !is_instance_valid(card):
        return
    await actions.execute(card, event)
    if from_hand:
        await draw_replacement()

func draw_replacement() -> void:
    var card := deck_candidates.draw_replacement() if deck_candidates.active else game.draw_card(GameRules.Side.PLAYER)
    if card && card.moving:
        await card.draw_finished

func eligible_cards(group: String) -> Array[Card]:
    var result: Array[Card]
    for card in game.player_hand.get_cards():
        if !card.is_queued_for_deletion() && RewardRules.belongs_to(card.card_name, group):
            result.append(card)
    return result

func show_message(card: Card, event: int) -> void:
    var actions_text := ["refuses to fight", "deserts your army", "betrays you"]
    message.text = "%s %s.\nPress any key to continue." % [card.card_name, actions_text[event]]
    show()

func wait_for_input() -> void:
    waiting = true
    await continued
    waiting = false

func execute(card: Card, event: int) -> void:
    var from_hand := card.get_parent() == game.player_hand
    await actions.execute(card, event)
    if from_hand:
        await draw_replacement()

func card_group(card: Card) -> String:
    return actions.card_group(card)

func log_check(result: Dictionary, card_name: String) -> void:
    checks_completed += 1
    var chances: Array = result["chances"]
    var event_name: String = "None" if result["event"] == -1 else LoyaltyRules.Event.keys()[result["event"]].capitalize()
    print("Loyalty check: roll=%d effective_loyalty=%d chances=[refuse=%d%%, desert=%d%%, betray=%d%%] card_to_remove=%s result=%s" % [result["roll"], result["effective_loyalty"], chances[0], chances[1], chances[2], card_name, event_name])

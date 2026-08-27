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
    if waiting && event.is_pressed() && !(event is InputEventKey && event.echo):
        get_viewport().set_input_as_handled()
        hide()
        continued.emit()

func run() -> void:
    if running:
        return
    running = true
    if CampaignState.is_act_2():
        await run_foreign_events()
    elif CampaignState.is_final_battle():
        await run_final_events()
    else:
        await run_regular_events()
    running = false
    hide()

func run_foreign_events() -> void:
    var factions := CampaignState.negative_foreign_factions()
    if CampaignState.is_act_2_boss():
        deck_candidates.capture_factions(factions)
        for card in eligible_foreign_cards(factions):
            await check_card(card, CampaignState.foreign_loyalty[card.faction])
        for candidate in deck_candidates.get_eligible():
            await check_candidate(candidate, CampaignState.foreign_loyalty[candidate["entry"].faction])
        return
    var cards := eligible_foreign_cards(factions)
    if !cards.is_empty():
        var card: Card = cards.pick_random()
        await check_card(card, CampaignState.foreign_loyalty[card.faction])

func run_final_events() -> void:
    var group := CampaignState.disloyal_group()
    deck_candidates.capture_group(group)
    for card in eligible_group_cards(group):
        await check_card(card, CampaignState.loyalty[group])
    for candidate in deck_candidates.get_eligible():
        await check_candidate(candidate, CampaignState.loyalty[group])

func run_regular_events() -> void:
    for group in CampaignState.loyalty:
        var cards := eligible_group_cards(group)
        if !cards.is_empty():
            await check_card(cards.pick_random(), CampaignState.loyalty[group])

func check_card(card: Card, value: int) -> void:
    if is_instance_valid(card):
        var result := LoyaltyRules.roll(value)
        log_check(result, card.card_name)
        if result["event"] != -1:
            await run_card_event(card, result["event"], true)

func check_candidate(candidate: Dictionary, value: int) -> void:
    var result := LoyaltyRules.roll(value)
    log_check(result, candidate["name"])
    if result["event"] != -1:
        await run_candidate_event(candidate, result["event"])

func run_candidate_event(candidate: Dictionary, event: int) -> void:
    var card: Card = deck_candidates.get_card(candidate)
    var from_hand := card != null
    if !from_hand && deck_candidates.remove_from_deck(candidate):
        card = actions.create_deck_card(candidate["entry"])
    if card:
        await run_card_event(card, event, from_hand)

func run_card_event(card: Card, event: int, from_hand := true) -> void:
    show_message(card, event)
    await wait_for_input()
    if is_instance_valid(card):
        await actions.execute(card, event)
        if from_hand:
            await draw_replacement()

func draw_replacement() -> void:
    var card: Card = deck_candidates.draw_replacement() if deck_candidates.active else game.draw_card(GameRules.Side.PLAYER)
    if card && card.moving:
        await card.draw_finished

func eligible_group_cards(group: String) -> Array[Card]:
    return game.player_hand.get_cards().filter(func(card: Card) -> bool: return !card.is_queued_for_deletion() && RewardRules.belongs_to(card.card_name, group))

func eligible_foreign_cards(factions: Array[int]) -> Array[Card]:
    return game.player_hand.get_cards().filter(func(card: Card) -> bool: return !card.is_queued_for_deletion() && factions.has(card.faction))

func show_message(card: Card, event: int) -> void:
    message.text = "%s %s.\nPress any key to continue." % [card.card_name, ["refuses to fight", "deserts your army", "betrays you"][event]]
    show()

func wait_for_input() -> void:
    waiting = true
    await continued
    waiting = false

func log_check(result: Dictionary, card_name: String) -> void:
    checks_completed += 1
    var chances: Array = result["chances"]
    var event_name: String = "None" if result["event"] == -1 else LoyaltyRules.Event.keys()[result["event"]].capitalize()
    print("Loyalty check: roll=%d loyalty=%d chances=[refuse=%d%%, desert=%d%%, betray=%d%%] card_to_remove=%s result=%s" % [result["roll"], result["loyalty"], chances[0], chances[1], chances[2], card_name, event_name])

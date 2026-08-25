class_name CardBattle extends Node2D

const CARD_SCENE := preload("res://Entities/Card/Card.tscn")

@export var enemy_deck: EnemyDeck
@onready var board: Board = $Board
@onready var player_hand: CardHand = $PlayerHand
@onready var enemy_hand: CardHand = $EnemyHand
@onready var player_discard: DiscardPile = $Interface/PlayerDiscard/Pile
@onready var enemy_discard: DiscardPile = $Interface/EnemyDiscard/Pile
@onready var battle: BattleResolver = $BattleResolver
@onready var battle_state: BattleState = $BattleState
@onready var turns: TurnState = $TurnState
@onready var loyalty_events: LoyaltyEvents = $LoyaltyEvents
@onready var status_label: Label = $Interface/Status
@onready var battle_hud: BattleHud = $Interface/BattleHud
@onready var result_panel: Panel = $Interface/Result
@onready var result_label: Label = $Interface/Result/Label
@onready var event_panel: Panel = $Interface/Event
@onready var event_message: Label = $Interface/Event/Message
@onready var audio: GameAudio = $Audio
@onready var fade: Fade = $Interface/Fade

var selectable_cards: Array[Card]
var finished := false

signal card_chosen(card: Card)

func _ready() -> void:
    audio.start_music()
    setup_states()
    connect_signals()
    add_starting_cards(CampaignState.player_deck, player_hand, GameRules.Side.PLAYER)
    add_starting_cards(enemy_deck.build(CampaignState.enemy_city()), enemy_hand, GameRules.Side.ENEMY)
    set_balance(0, false)
    await loyalty_events.run()
    turns.start_round()

func setup_states() -> void:
    battle.setup(self)
    battle_state.setup(self)
    turns.setup(self)
    loyalty_events.setup(self)

func connect_signals() -> void:
    board.target_chosen.connect(_on_target_chosen)
    board.state_changed.connect(battle.update_preview)
    player_discard.target_chosen.connect(turns.discard_clicked)
    player_hand.card_clicked.connect(turns.card_clicked)
    player_hand.card_released.connect(turns.card_released)
    player_hand.card_cancelled.connect(turns.card_cancelled)

func _input(event: InputEvent) -> void:
    if selectable_cards.is_empty() || !(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed):
        return
    var slot := board.get_target_at(event.position)
    var card := slot.get_card() if slot else null
    print("[BattleTarget] input position=%s card=%s" % [event.position, card.card_name if card else "none"])

func _on_target_chosen(slot: CardSlot) -> void:
    var card := slot.get_card()
    if !selectable_cards.is_empty():
        print("[BattleTarget] accepted card=%s" % (card.card_name if card else "none"))
    if selectable_cards.has(card):
        card_chosen.emit(card)
    else:
        turns.target_clicked(slot)

func add_starting_cards(names: Array[String], hand: CardHand, side: int) -> void:
    for card_name in names:
        hand.add_card(create_card(card_name, side))

func create_card(card_name: String, side: int) -> Card:
    var card := CARD_SCENE.instantiate() as Card
    card.card_name = card_name
    card.side = side
    return card

func choose_card(cards: Array[Card], prompt: String) -> Card:
    selectable_cards.assign(cards)
    print("[BattleTarget] offered prompt=%s cards=%s" % [prompt, cards.map(func(card: Card) -> String: return card.card_name)])
    set_status(prompt)
    board.enable_card_targets(selectable_cards)
    var chosen: Card = await card_chosen
    board.clear_targets()
    selectable_cards.clear()
    return chosen

func defeat_card(card: Card) -> void:
    card.reparent(self)
    board.notify_state_changed()
    await card.fade_out()
    get_discard(card.side).add_defeated(card)

func discard_card(card: Card) -> void:
    get_discard(card.side).add_card(card)

func get_discard(side: int) -> DiscardPile:
    return player_discard if side == GameRules.Side.PLAYER else enemy_discard

func set_losses(player: int, enemy: int) -> void:
    battle_hud.set_losses(player, enemy)

func preview_balance(difference: int) -> void:
    battle_hud.set_preview(battle_state.balance + difference)

func set_balance(value: int, animate := true) -> void:
    battle_hud.set_balance(value, animate)

func set_status(value: String) -> void:
    status_label.text = value

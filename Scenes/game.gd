class_name CardGame extends Node2D

const CARD_SCENE := preload("res://Entities/Card/Card.tscn")

@export var player_cards: Array[String]
@export var enemy_cards: Array[String]
@onready var board: Board = $Board
@onready var player_hand: CardHand = $PlayerHand
@onready var enemy_hand: CardHand = $EnemyHand
@onready var player_discard: DiscardPile = $PlayerDiscard
@onready var enemy_discard: DiscardPile = $EnemyDiscard
@onready var battle: BattleResolver = $BattleResolver
@onready var battle_state: BattleState = $BattleState
@onready var turns: TurnState = $TurnState
@onready var status_label: Label = $Interface/Status
@onready var strength_label: Label = $Interface/Strength
@onready var result_panel: Panel = $Interface/Result
@onready var result_label: Label = $Interface/Result/Label

var selectable_cards: Array[Card]
var finished := false

signal card_chosen(card: Card)

func _ready() -> void:
    battle.setup(self)
    battle_state.setup(self)
    turns.setup(self)
    board.target_chosen.connect(_on_target_chosen)
    player_discard.target_chosen.connect(turns.discard_clicked)
    player_hand.card_clicked.connect(turns.card_clicked)
    player_hand.card_released.connect(turns.card_released)
    player_hand.card_cancelled.connect(turns.card_cancelled)
    add_starting_cards(player_cards, player_hand, GameRules.Side.PLAYER)
    add_starting_cards(enemy_cards, enemy_hand, GameRules.Side.ENEMY)
    turns.start_round()

func _on_target_chosen(slot: CardSlot) -> void:
    var card := slot.get_card()
    if selectable_cards.has(card):
        card_chosen.emit(card)
    else:
        turns.target_clicked(slot)

func add_starting_cards(names: Array[String], hand: CardHand, side: int) -> void:
    for card_name in names:
        var card := create_card(card_name, side)
        hand.add_card(card)

func create_card(card_name: String, side: int) -> Card:
    var card := CARD_SCENE.instantiate() as Card
    card.card_name = card_name
    card.side = side
    return card

func choose_card(cards: Array[Card], prompt: String) -> Card:
    selectable_cards.assign(cards)
    set_status(prompt)
    board.enable_card_targets(selectable_cards)
    var chosen: Card = await card_chosen
    board.clear_targets()
    selectable_cards.clear()
    return chosen

func defeat_card(card: Card) -> void:
    card.reparent(self)
    await card.fade_out()
    get_discard(card.side).add_defeated(card)

func discard_card(card: Card) -> void:
    get_discard(card.side).add_card(card)

func get_discard(side: int) -> DiscardPile:
    return player_discard if side == GameRules.Side.PLAYER else enemy_discard

func set_status(value: String) -> void:
    status_label.text = value

func set_strengths(player_strength: int, enemy_strength: int) -> void:
    strength_label.text = "Player %d strength   Enemy %d strength" % [player_strength, enemy_strength]

func finish_game(winner: int) -> void:
    finished = true
    player_hand.set_draggable(false)
    result_panel.show()
    if winner == -1:
        result_label.text = "DRAW"
    elif winner == GameRules.Side.PLAYER:
        result_label.text = "PLAYER VICTORY"
    else:
        result_label.text = "ENEMY VICTORY"
    set_status("Game over")

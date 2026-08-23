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
@onready var front_label: Label = $Interface/Front
@onready var result_panel: Panel = $Interface/Result
@onready var result_label: Label = $Interface/Result/Label

var selectable_cards: Array[Card]
var finished := false

signal card_chosen(card: Card)

func _ready() -> void:
    battle.setup(self)
    battle_state.setup(self)
    turns.setup(self)
    add_starting_cards(player_cards, player_hand, GameRules.Side.PLAYER)
    add_starting_cards(enemy_cards, enemy_hand, GameRules.Side.ENEMY)
    update_front_text()
    turns.start_round()

func add_starting_cards(names: Array[String], hand: CardHand, side: int) -> void:
    for card_name in names:
        var card := create_card(card_name, side)
        hand.add_card(card)

func create_card(card_name: String, side: int) -> Card:
    var card := CARD_SCENE.instantiate() as Card
    card.card_name = card_name
    card.side = side
    card.dropped.connect(_on_card_dropped)
    card.selected.connect(_on_card_selected)
    return card

func _on_card_dropped(card: Card, point: Vector2) -> void:
    turns.card_dropped(card, point)

func _on_card_selected(card: Card) -> void:
    if selectable_cards.has(card):
        card_chosen.emit(card)

func choose_card(cards: Array[Card], prompt: String) -> Card:
    selectable_cards.assign(cards)
    set_status(prompt)
    for card in selectable_cards:
        card.set_selectable(true)
    var chosen: Card = await card_chosen
    for card in selectable_cards:
        card.set_selectable(false)
    selectable_cards.clear()
    return chosen

func discard_card(card: Card) -> void:
    if card.side == GameRules.Side.PLAYER:
        player_discard.add_card(card)
    else:
        enemy_discard.add_card(card)

func set_status(value: String) -> void:
    status_label.text = value

func set_strengths(player_strength: int, enemy_strength: int) -> void:
    strength_label.text = "Player %d strength   Enemy %d strength" % [player_strength, enemy_strength]

func update_front_text() -> void:
    front_label.text = "Enemy row %d   Player row %d" % [board.enemy_row + 1, board.player_row + 1]

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

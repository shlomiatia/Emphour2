class_name CardGame extends Node2D

const CARD_SCENE := preload("res://Entities/Card/Card.tscn")

@export var player_cards: Array[String]
@export var enemy_cards: Array[String]
@onready var board: Board = $Board
@onready var player_hand: CardHand = $PlayerHand
@onready var enemy_hand: CardHand = $EnemyHand
@onready var player_discard: DiscardPile = $Interface/PlayerDiscard/Pile
@onready var enemy_discard: DiscardPile = $Interface/EnemyDiscard/Pile
@onready var battle: BattleResolver = $BattleResolver
@onready var battle_state: BattleState = $BattleState
@onready var turns: TurnState = $TurnState
@onready var status_label: Label = $Interface/Status
@onready var status_background: ColorRect = $Interface/StatusBackground
@onready var strength_label: RichTextLabel = $Interface/Strength
@onready var result_panel: Panel = $Interface/Result
@onready var result_label: Label = $Interface/Result/Label
@onready var audio: GameAudio = $Audio

var selectable_cards: Array[Card]
var finished := false

signal card_chosen(card: Card)

func _ready() -> void:
    audio.start_music()
    battle.setup(self)
    battle_state.setup(self)
    turns.setup(self)
    board.target_chosen.connect(_on_target_chosen)
    board.state_changed.connect(battle.update_strengths)
    player_discard.target_chosen.connect(turns.discard_clicked)
    player_hand.card_clicked.connect(turns.card_clicked)
    player_hand.card_released.connect(turns.card_released)
    player_hand.card_cancelled.connect(turns.card_cancelled)
    add_starting_cards(player_cards, player_hand, GameRules.Side.PLAYER)
    add_starting_cards(enemy_cards, enemy_hand, GameRules.Side.ENEMY)
    set_status(status_label.text)
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
    board.notify_state_changed()
    await card.fade_out()
    get_discard(card.side).add_defeated(card)

func discard_card(card: Card) -> void:
    get_discard(card.side).add_card(card)

func play_card_sound() -> void:
    audio.play_card()

func play_attack_sound() -> void:
    audio.play_attack()

func play_block_sound() -> void:
    audio.play_block()

func get_discard(side: int) -> DiscardPile:
    return player_discard if side == GameRules.Side.PLAYER else enemy_discard

func set_status(value: String) -> void:
    status_label.text = value
    status_label.reset_size()
    status_background.size = status_label.size + Vector2(20, 12)

func set_strengths(player_strength: int, enemy_strength: int, player_losses: int, enemy_losses: int) -> void:
    var strength_color := "76d275" if player_strength > enemy_strength else "ef5b5b" if player_strength < enemy_strength else "ffffff"
    var loss_color := "ef5b5b" if player_losses > 0 else "ffffff"
    var enemy_loss_color := "76d275" if enemy_losses > 0 else "ffffff"
    strength_label.text = "[color=#%s]Player strength %d[/color]\nEnemy strength %d\n[color=#%s]Player potential losses %d[/color]\n[color=#%s]Enemy potential losses %d[/color]" % [strength_color, player_strength, enemy_strength, loss_color, player_losses, enemy_loss_color, enemy_losses]

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

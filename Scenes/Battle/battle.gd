class_name CardBattle extends Node2D

const CARD_SCENE := preload("res://Entities/Card/Card.tscn")

@export var enemy_deck: EnemyDeck
@onready var board: Board = $CardLayer/Board
@onready var shaking_camera: ShakingCamera = $ShakingCamera
@onready var player_hand: CardHand = $CardLayer/PlayerHand
@onready var enemy_hand: CardHand = $CardLayer/EnemyHand
@onready var player_discard: DiscardPile = $Interface/PlayerDiscard/Pile
@onready var enemy_discard: DiscardPile = $Interface/EnemyDiscard/Pile
@onready var battle: BattleResolver = $BattleResolver
@onready var battle_state: BattleState = $BattleState
@onready var turns: TurnState = $TurnState
@onready var loyalty_events: LoyaltyEvents = $LoyaltyEvents
@onready var status_label: Label = $CardLayer/StatusBackground/MarginContainer/Status
@onready var battle_hud: BattleHud = $CardLayer/BattleHud
@onready var event_panel: Panel = $Interface/Event
@onready var event_message: Label = $Interface/Event/Message
@onready var audio: GameAudio = Audio
@onready var fade: Fade = $Interface/Fade

var selectable_cards: Array[Card]
var player_draw_pile: Array[String]
var enemy_draw_pile: Array[String]
var finished := false
var can_restart := false

signal card_chosen(card: Card)

func _ready() -> void:
    audio.start_music()
    board.slot_count = CampaignState.battle_slot_count()
    setup_states()
    connect_signals()
    setup_draw_pile(CampaignState.player_deck, player_draw_pile)
    setup_draw_pile(enemy_deck.build(CampaignState.enemy_city()), enemy_draw_pile)
    draw_cards(player_hand, GameRules.Side.PLAYER, 5)
    draw_cards(enemy_hand, GameRules.Side.ENEMY, 5)
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
    if can_restart && event.is_pressed():
        CampaignState.reset()
        get_tree().change_scene_to_file("res://Scenes/Map/Map.tscn")
        return
    if selectable_cards.is_empty() || !(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed):
        return
    var slot := board.get_target_at(event.position)
    var card := slot.get_card() if slot else null

func _on_target_chosen(slot: CardSlot) -> void:
    var card := slot.get_card()
    if selectable_cards.has(card):
        card_chosen.emit(card)
    else:
        turns.target_clicked(slot)

func setup_draw_pile(names: Array[String], pile: Array[String]) -> void:
    pile.assign(names)
    pile.shuffle()

func draw_cards(hand: CardHand, side: int, count: int) -> void:
    for _card in count:
        var pile := get_draw_pile(side)
        if pile.is_empty():
            return
        hand.add_card(create_card(pile.pop_back(), side))

func draw_card(side: int) -> void:
    draw_cards(player_hand if side == GameRules.Side.PLAYER else enemy_hand, side, 1)

func get_draw_pile(side: int) -> Array[String]:
    return player_draw_pile if side == GameRules.Side.PLAYER else enemy_draw_pile

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
    battle_hud.remove_loss(card.side)
    card.reparent(self)
    board.notify_state_changed()
    await card.fade_out()
    get_discard(card.side).add_defeated(card)

func shake_camera() -> void:
    shaking_camera.shake()

func discard_card(card: Card) -> void:
    var discard := get_discard(card.side)
    card.reparent(self)
    discard.add_card(card, false)
    card.move_to_discard(discard.global_position)

func get_discard(side: int) -> DiscardPile:
    return player_discard if side == GameRules.Side.PLAYER else enemy_discard

func set_losses(player: int, enemy: int) -> void:
    battle_hud.set_losses(player, enemy)

func fade_losses() -> Signal:
    return battle_hud.fade_losses()

func preview_balance(difference: int) -> void:
    battle_hud.set_preview(battle_state.balance + difference)

func set_balance(value: int, animate := true) -> void:
    battle_hud.set_balance(value, animate)

func set_status(value: String) -> void:
    status_label.text = value

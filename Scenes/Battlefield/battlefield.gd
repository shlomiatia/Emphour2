class_name CardBattle extends Node2D

@export var enemy_deck: EnemyDeck
@onready var card_space: CanvasLayer = $CardSpace
@onready var board: Board = $CardSpace/Board
@onready var shaking_camera: ShakingCamera = $ShakingCamera
@onready var player_hand: CardHand = $CardSpace/PlayerHand
@onready var enemy_hand: CardHand = $Interface/EnemyHand
@onready var player_discard: DiscardPile = $Interface/PlayerDiscard/Pile
@onready var enemy_discard: DiscardPile = $Interface/EnemyDiscard/Pile
@onready var player_deck: CardDeck = $Interface/PlayerDeck/Pile
@onready var enemy_deck_pile: CardDeck = $Interface/EnemyDeck/Pile
@onready var battle_state: BattleState = $BattleState
@onready var turns: TurnState = $TurnState
@onready var loyalty_events: LoyaltyEvents = $Overlay/LoyaltyEvents
@onready var status_label: Label = $Interface/StatusBackground/MarginContainer/Status
@onready var battle_hud: BattleHud = $Interface/BattleHud
@onready var audio: GameAudio = get_node("/root/Audio")
@onready var fade: Fade = $Overlay/Fade
@onready var tutorial: BattleTutorial = $BattleTutorial

var battle := BattleResolver.new()
var draws := BattleDraws.new()
var selectable_cards: Array[Card]
var player_draw_pile: Array[CampaignCard]
var enemy_draw_pile: Array[String]
var finished := false
var can_restart := false

signal card_chosen(card: Card)
signal battle_ready

func _ready() -> void:
    start_music()
    board.slot_count = CampaignState.battle_slot_count()
    setup_states()
    connect_signals()
    draws.setup_piles(CampaignState.player_deck, tutorial.enemy_cards(enemy_deck.build(CampaignState.selected_city)))
    set_balance(0, false)
    await draws.draw_opening_hands()
    await loyalty_events.run()
    turns.start_round()
    tutorial.start()
    await get_tree().process_frame
    battle_ready.emit()

func start_music() -> void:
    if CampaignState.is_act_1_boss() || CampaignState.is_act_2_boss():
        audio.start_boss_music()
        return
    audio.start_general_music()

func setup_states() -> void:
    battle.setup(self)
    battle_state.setup(self)
    turns.setup(self)
    loyalty_events.setup(self)
    draws.setup(self)
    tutorial.setup(self)

func connect_signals() -> void:
    board.target_chosen.connect(_on_target_chosen)
    board.state_changed.connect(battle.update_preview)
    player_discard.target_chosen.connect(turns.discard_clicked)
    player_hand.card_clicked.connect(turns.card_clicked)
    player_hand.card_released.connect(turns.card_released)
    player_hand.card_cancelled.connect(turns.card_cancelled)

func _input(event: InputEvent) -> void:
    if can_restart && event.is_pressed():
        battle_state.restart()
        return

func _on_target_chosen(slot: CardSlot) -> void:
    var card := slot.get_card()
    if selectable_cards.has(card):
        card_chosen.emit(card)
    else:
        turns.target_clicked(slot)

func draw_card(side: int) -> Card:
    return draws.draw_card(side)

func create_card(card_name: String, side: int) -> Card:
    var faction := CampaignState.Faction.FRANKS if side == GameRules.Side.PLAYER else CampaignState.battlefield_faction()
    return CardFactory.create(card_name, side, faction)

func choose_card(cards: Array[Card], prompt: String) -> Card:
    selectable_cards.assign(await tutorial.prepare_choices(cards))
    set_status(prompt)
    board.enable_card_targets(selectable_cards)
    player_hand.set_draggable_cards([])
    var chosen: Card = await card_chosen
    tutorial.choice_selected()
    board.clear_targets()
    player_hand.set_draggable(false)
    selectable_cards.clear()
    return chosen

func defeat_card(card: Card) -> void:
    battle_hud.remove_loss(card.side)
    card.reparent(card_space)
    board.notify_state_changed()
    await card.fade_out()
    get_discard(card.side).add_card(card)

func shake_camera() -> void:
    shaking_camera.shake()

func discard_card(card: Card) -> void:
    var discard := get_discard(card.side)
    card.reparent(card_space)
    discard.add_card(card, false)
    await card.move_to(discard.global_position, true, Vector2.ZERO)
    card.queue_free()

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

func set_status(value: String, color := BattleHud.NORMAL_COLOR) -> void:
    status_label.text = value
    status_label.add_theme_color_override("font_color", color)
    status_label.add_theme_constant_override("outline_size", 4 if color != BattleHud.NORMAL_COLOR else 0)

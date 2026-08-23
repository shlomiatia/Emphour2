class_name TurnState extends Node

var game: CardGame
var pending_enemy: Card
var accepting_action := false

func setup(card_game: CardGame) -> void:
    game = card_game

func start_round() -> void:
    if game.finished || game.battle_state.active:
        return
    if hands_empty():
        game.battle_state.start(true)
        return
    play_enemy_card()
    if game.player_hand.get_card_count() > 0:
        begin_player_action()
    else:
        reveal_enemy_card()
        await complete_round()

func play_enemy_card() -> void:
    pending_enemy = null
    if game.enemy_hand.get_card_count() == 0:
        return
    pending_enemy = game.enemy_hand.get_cards()[0]
    pending_enemy.set_hidden(true)
    if !game.board.play_leftmost(pending_enemy, GameRules.Side.ENEMY):
        game.discard_card(game.board.replace_first(pending_enemy, GameRules.Side.ENEMY))

func begin_player_action() -> void:
    accepting_action = true
    game.player_hand.set_draggable(true)
    if game.board.is_full(GameRules.Side.PLAYER):
        game.set_status("Replace a battlefield card, or drag a card to your discard pile")
    else:
        game.set_status("Drag one card to your highlighted row")

func card_dropped(card: Card, point: Vector2) -> void:
    if !accepting_action || card.get_parent() != game.player_hand:
        return
    if game.player_discard.contains_point(point) && game.board.is_full(GameRules.Side.PLAYER):
        game.discard_card(card)
        finish_player_action()
    elif game.board.contains_row_point(point, GameRules.Side.PLAYER):
        play_player_card(card, point)

func play_player_card(card: Card, point: Vector2) -> void:
    if game.board.is_full(GameRules.Side.PLAYER):
        var replaced := game.board.replace_at(card, point, GameRules.Side.PLAYER)
        if !replaced:
            return
        game.discard_card(replaced)
    elif !game.board.play_leftmost(card, GameRules.Side.PLAYER):
        return
    finish_player_action()

func finish_player_action() -> void:
    accepting_action = false
    game.player_hand.set_draggable(false)
    reveal_enemy_card()
    complete_round()

func reveal_enemy_card() -> void:
    if pending_enemy:
        pending_enemy.set_hidden(false)
        pending_enemy = null

func complete_round() -> void:
    if battle_needed():
        game.battle_state.start(hands_empty())
    else:
        await get_tree().create_timer(0.2).timeout
        start_round()

func battle_needed() -> bool:
    return game.board.is_full(GameRules.Side.PLAYER) || game.board.is_full(GameRules.Side.ENEMY) || hands_empty()

func hands_empty() -> bool:
    return game.player_hand.get_card_count() == 0 && game.enemy_hand.get_card_count() == 0

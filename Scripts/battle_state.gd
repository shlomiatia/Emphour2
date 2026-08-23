class_name BattleState extends Node

var game: CardGame
var active := false

func setup(card_game: CardGame) -> void:
    game = card_game

func start(final_battle: bool) -> void:
    active = true
    game.turns.accepting_action = false
    game.player_hand.set_draggable(false)
    game.board.reveal_enemy_cards()
    game.set_status("Battle")
    await get_tree().create_timer(0.35).timeout
    var winner := await game.battle.resolve()
    await finish(winner, final_battle)

func finish(winner: int, final_battle: bool) -> void:
    if final_battle:
        finish_final(winner)
        return
    if winner != -1 && push_front(winner):
        return
    active = false
    game.update_front_text()
    await get_tree().create_timer(0.35).timeout
    game.turns.start_round()

func push_front(winner: int) -> bool:
    var result := game.board.advance(winner)
    for card in result["ejected"]:
        game.discard_card(card)
    if result["finished"]:
        game.finish_game(winner)
        return true
    return false

func finish_final(winner: int) -> void:
    if winner == -1:
        winner = territory_winner()
    if winner != -1:
        game.board.advance_to_end(winner)
        game.update_front_text()
    game.finish_game(winner)

func territory_winner() -> int:
    if game.board.player_row < 2:
        return GameRules.Side.PLAYER
    if game.board.enemy_row > 1:
        return GameRules.Side.ENEMY
    return -1

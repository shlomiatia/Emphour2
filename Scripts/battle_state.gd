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
    var decisive_winner := game.battle.empty_hand_winner()
    if decisive_winner != -1:
        await finish_decisive(decisive_winner)
        return
    if final_battle:
        await finish_final(winner)
        return
    if winner != -1 && push_front(winner):
        await get_tree().create_timer(0.35).timeout
        game.finish_game(winner)
        return
    active = false
    await get_tree().create_timer(0.35).timeout
    game.turns.start_round()

func finish_decisive(winner: int) -> void:
    active = true
    game.turns.accepting_action = false
    game.player_hand.set_draggable(false)
    game.board.reveal_enemy_cards()
    game.set_status("Victory")
    game.board.advance_to_end(winner)
    await get_tree().create_timer(0.35).timeout
    game.finish_game(winner)

func push_front(winner: int) -> bool:
    var result := game.board.advance(winner)
    return result["finished"]

func finish_final(winner: int) -> void:
    if winner == -1:
        winner = territory_winner()
    if winner != -1:
        game.board.advance_to_end(winner)
        await get_tree().create_timer(0.35).timeout
    game.finish_game(winner)

func territory_winner() -> int:
    if game.board.player_row < 2:
        return GameRules.Side.PLAYER
    if game.board.enemy_row > 1:
        return GameRules.Side.ENEMY
    return -1

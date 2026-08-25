class_name BattleState extends Node

var game: CardGame
var active := false
var balance := 0

func setup(card_game: CardGame) -> void:
    game = card_game

func start(final_battle: bool) -> void:
    active = true
    game.turns.accepting_action = false
    game.player_hand.set_draggable(false)
    game.board.reveal_enemy_cards()
    game.set_status("Battle")
    await get_tree().create_timer(0.35).timeout
    var difference := await game.battle.resolve()
    await finish(difference, final_battle)

func finish(difference: int, final_battle: bool) -> void:
    balance += difference
    game.set_balance(balance)
    var winner := score_winner()
    if winner != -1:
        game.set_status("Balance of power reached %s" % balance)
        await get_tree().create_timer(0.35).timeout
        game.finish_game(winner)
        return
    if final_battle:
        await get_tree().create_timer(0.35).timeout
        game.finish_game(balance_winner())
        return
    active = false
    await get_tree().create_timer(0.35).timeout
    game.turns.start_round()

func score_winner() -> int:
    if balance >= GameRules.WINNING_SCORE:
        return GameRules.Side.PLAYER
    if balance <= -GameRules.WINNING_SCORE:
        return GameRules.Side.ENEMY
    return -1

func balance_winner() -> int:
    if balance == 0:
        return -1
    return GameRules.Side.PLAYER if balance > 0 else GameRules.Side.ENEMY

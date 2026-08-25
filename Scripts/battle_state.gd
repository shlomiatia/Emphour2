class_name BattleState extends Node

var game: CardBattle
var active := false
var balance := 0

func setup(card_game: CardBattle) -> void:
    game = card_game

func start(final_battle: bool) -> void:
    game.turns.accepting_action = false
    game.player_hand.set_draggable(false)
    game.board.reveal_enemy_cards()
    active = true
    game.set_status("Battle")
    await get_tree().create_timer(0.35).timeout
    await move_balance(game.battle.strength_difference())
    await game.battle.resolve()
    await finish(final_battle)

func move_balance(difference: int) -> void:
    balance += difference
    game.set_balance(balance)
    await get_tree().create_timer(0.45).timeout

func finish(final_battle: bool) -> void:
    var winner := score_winner()
    if winner != -1:
        game.set_status("Balance of power reached %s" % balance)
        await get_tree().create_timer(0.35).timeout
        finish_game(winner)
        return
    if final_battle:
        await get_tree().create_timer(0.35).timeout
        finish_game(balance_winner())
        return
    active = false
    game.battle.update_preview()
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

func finish_game(winner: int) -> void:
    game.finished = true
    game.player_hand.set_draggable(false)
    game.result_panel.show()
    game.result_label.text = result_text(winner)
    game.set_status("Game over")
    if winner == GameRules.Side.PLAYER:
        open_rewards()

func result_text(winner: int) -> String:
    if winner == -1:
        return "DRAW"
    return "PLAYER VICTORY" if winner == GameRules.Side.PLAYER else "ENEMY VICTORY"

func open_rewards() -> void:
    await get_tree().create_timer(0.8).timeout
    await game.fade.fade_out()
    get_tree().change_scene_to_file("res://Scenes/Reward/Reward.tscn")

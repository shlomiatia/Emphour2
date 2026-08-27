class_name BattleState extends Node

var game: CardBattle
var active := false
var balance := 0
var entry_deck: Array[String]
var entry_public_loyalty: Dictionary
var entry_internal_loyalty: Dictionary

func setup(card_game: CardBattle) -> void:
    game = card_game
    entry_deck.assign(CampaignState.player_deck)
    entry_public_loyalty = CampaignState.public_loyalty.duplicate()
    entry_internal_loyalty = CampaignState.internal_loyalty.duplicate()

func start() -> void:
    if active:
        return
    active = true
    game.turns.accepting_action = false
    game.player_hand.set_draggable(false)
    await game.turns.reveal_enemy_card()
    await game.battle_hud.wait_for_preview()
    game.set_status("Battle", BattleHud.ENEMY_COLOR)
    await get_tree().create_timer(1.0).timeout
    await move_balance(game.battle.strength_difference())
    await game.battle.resolve()
    await finish(game.player_hand.get_card_count() == 0 && game.enemy_hand.get_card_count() == 0)

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
    if game.turns.enemy_defeated():
        finish_game(GameRules.Side.PLAYER)
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
    game.set_status(result_text(winner), result_color(winner))
    if winner == GameRules.Side.PLAYER:
        open_rewards()
    else:
        game.can_restart = true

func result_text(winner: int) -> String:
    if winner == -1:
        return "Draw"
    return "Player win" if winner == GameRules.Side.PLAYER else "Game over\nPress any key to restart level"

func result_color(winner: int) -> Color:
    if winner == GameRules.Side.PLAYER:
        return BattleHud.PLAYER_COLOR
    return BattleHud.NORMAL_COLOR if winner == -1 else BattleHud.ENEMY_COLOR

func restart() -> void:
    restore_entry_state()
    get_tree().change_scene_to_file("res://Scenes/Battle/Battle.tscn")

func restore_entry_state() -> void:
    CampaignState.player_deck.assign(entry_deck)
    CampaignState.public_loyalty = entry_public_loyalty.duplicate()
    CampaignState.internal_loyalty = entry_internal_loyalty.duplicate()

func open_rewards() -> void:
    await get_tree().create_timer(0.8).timeout
    await game.fade.fade_out()
    get_tree().change_scene_to_file("res://Scenes/Reward/Reward.tscn")

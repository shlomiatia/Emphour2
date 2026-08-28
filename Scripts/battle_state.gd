class_name BattleState extends Node

const MESSAGE_DURATION := 0.8

var game: CardBattle
var active := false
var balance := 0
var entry_deck: Array[CampaignCard]
var entry_loyalty: Dictionary

func setup(card_game: CardBattle) -> void:
    game = card_game
    entry_deck = CampaignState.copy_deck(CampaignState.player_deck)
    entry_loyalty = CampaignState.loyalty.duplicate()

func start() -> void:
    if active:
        return
    active = true
    game.turns.accepting_action = false
    game.player_hand.set_draggable(false)
    game.set_status(tr("battle.start"), BattleHud.ENEMY_COLOR)
    var delay := get_tree().create_timer(MESSAGE_DURATION).timeout
    await game.turns.reveal_enemy_card()
    await delay
    var difference := game.battle.strength_difference()
    game.fade_losses()
    move_balance(difference)
    if difference != 0:
        await game.audio.push.finished
    await game.battle.resolve()
    await finish(game.player_hand.get_card_count() == 0 && game.enemy_hand.get_card_count() == 0)

func move_balance(difference: int) -> void:
    balance += difference
    if difference != 0:
        game.audio.play_push()
    game.set_balance(balance)

func finish(final_battle: bool) -> void:
    var winner := score_winner()
    if winner != -1:
        finish_game(winner)
        return
    if game.turns.enemy_defeated():
        finish_game(GameRules.Side.PLAYER)
        return
    if final_battle:
        await get_tree().create_timer(0.35).timeout
        finish_game(balance_winner())
        return
    if await game.tutorial.after_battle():
        active = false
        start()
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
    game.audio.play_result(winner == GameRules.Side.PLAYER)
    if winner == GameRules.Side.PLAYER:
        open_rewards()
    else:
        game.can_restart = true

func result_text(winner: int) -> String:
    if winner == -1:
        return tr("battle.restart") % tr("battle.draw")
    var faction := CampaignState.Faction.FRANKS if winner == GameRules.Side.PLAYER else CampaignState.battlefield_faction()
    var text := tr("battle.win") % CampaignState.faction_name(faction)
    return text if winner == GameRules.Side.PLAYER else tr("battle.restart") % text

func result_color(winner: int) -> Color:
    if winner == GameRules.Side.PLAYER:
        return BattleHud.PLAYER_COLOR
    return BattleHud.NORMAL_COLOR if winner == -1 else BattleHud.ENEMY_COLOR

func restart() -> void:
    restore_entry_state()
    get_tree().change_scene_to_file("res://Scenes/Battlefield/Battlefield.tscn")

func restore_entry_state() -> void:
    CampaignState.player_deck = CampaignState.copy_deck(entry_deck)
    CampaignState.loyalty = entry_loyalty.duplicate()

func open_rewards() -> void:
    await get_tree().create_timer(MESSAGE_DURATION).timeout
    await game.fade.fade_out()
    if CampaignState.is_act_2() && CampaignState.is_act_2_boss():
        CampaignState.capture_selected_city()
        get_tree().change_scene_to_file("res://Scenes/Intro/Intro.tscn")
        return
    get_tree().change_scene_to_file("res://Scenes/Reward/Reward.tscn")

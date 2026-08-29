class_name TurnState extends Node

signal player_action_started

var game: CardBattle
var pending_enemy: Card
var selected_card: Card
var accepting_action := false
var forced_enemy_cards: Array[String]
var allowed_slots: Array[CardSlot]
var discard_allowed := true

func setup(card_game: CardBattle) -> void:
    game = card_game

func start_round() -> void:
    if game.finished || game.battle_state.active:
        return
    if enemy_defeated():
        game.battle_state.finish_game(GameRules.Side.PLAYER)
        return
    play_enemy_card()
    if game.player_hand.get_card_count() == 0:
        complete_round()
        return
    begin_player_action()

func play_enemy_card() -> void:
    pending_enemy = null
    if game.enemy_hand.get_card_count() == 0:
        return
    pending_enemy = choose_enemy_card()
    game.audio.play_card()
    pending_enemy.set_hidden(true)
    if !game.board.play_leftmost(pending_enemy, GameRules.Side.ENEMY):
        if randf() < 0.5:
            discard_enemy_card()
        else:
            game.discard_card(game.board.replace_random(pending_enemy, GameRules.Side.ENEMY))
    game.draw_card(GameRules.Side.ENEMY)

func choose_enemy_card() -> Card:
    if !forced_enemy_cards.is_empty():
        var name: String = forced_enemy_cards.pop_front()
        for card in game.enemy_hand.get_cards():
            if card.card_name == name:
                return card
    return game.enemy_hand.get_cards().pick_random()

func set_enemy_plays(cards: Array[String]) -> void:
    forced_enemy_cards = cards.duplicate()

func set_allowed_slots(slots: Array[CardSlot], can_discard: bool) -> void:
    allowed_slots = slots
    discard_allowed = can_discard

func discard_enemy_card() -> void:
    game.discard_card(pending_enemy)
    pending_enemy = null

func begin_player_action() -> void:
    accepting_action = true
    game.player_hand.set_draggable(true)
    game.set_status(tr("turn.choose_card"))
    player_action_started.emit()

func card_clicked(card: Card) -> void:
    if !accepting_action || card.get_parent() != game.player_hand:
        return
    game.audio.play_card()
    selected_card = card
    enable_targets()

func enable_targets() -> void:
    var full_row := game.board.is_full(GameRules.Side.PLAYER)
    game.board.enable_player_targets()
    if !allowed_slots.is_empty():
        game.board.limit_targets(allowed_slots)
    game.board.set_dragged_card(selected_card)
    game.player_discard.set_targetable(full_row && discard_allowed)
    game.player_discard.set_dragged_card(selected_card)
    game.set_status(tr("turn.discard_or_replace") if full_row else tr("turn.play_card"))

func target_clicked(slot: CardSlot) -> void:
    if !selected_card:
        return
    if game.board.is_full(GameRules.Side.PLAYER):
        var replaced := game.board.replace_at(selected_card, slot, GameRules.Side.PLAYER)
        if !replaced:
            return
        game.discard_card(replaced)
    elif !game.board.play_leftmost(selected_card, GameRules.Side.PLAYER):
        return
    finish_player_action()

func discard_clicked() -> void:
    if selected_card && game.board.is_full(GameRules.Side.PLAYER):
        game.discard_card(selected_card)
        finish_player_action()

func card_released(card: Card) -> void:
    if card != selected_card:
        return
    if game.player_discard.targetable && game.player_discard.overlaps(card):
        discard_clicked()
        return
    var slot := game.board.get_overlap_target(card)
    if slot:
        target_clicked(slot)
        return
    clear_targets()

func card_cancelled() -> void:
    clear_targets()

func finish_player_action() -> void:
    game.audio.play_card()
    accepting_action = false
    game.player_hand.set_draggable(false)
    clear_targets()
    await game.tutorial.after_player_action()
    game.draw_card(GameRules.Side.PLAYER)
    game.battle.update_preview()
    complete_round()

func clear_targets() -> void:
    selected_card = null
    game.board.clear_targets()
    game.player_discard.set_targetable(false)

func reveal_enemy_card() -> void:
    if pending_enemy:
        await pending_enemy.flip_face_up()
        pending_enemy = null
    game.board.notify_state_changed()

func complete_round() -> void:
    if battle_needed():
        game.battle_state.start()
    else:
        await reveal_enemy_card()
        start_round()

func battle_needed() -> bool:
    var player_has_cards := game.player_hand.get_card_count() > 0
    var enemy_has_cards := game.enemy_hand.get_card_count() > 0
    if !player_has_cards && !enemy_has_cards:
        return true
    return game.board.is_full(GameRules.Side.PLAYER) || game.board.is_full(GameRules.Side.ENEMY)

func enemy_defeated() -> bool:
    return game.enemy_hand.get_card_count() == 0 && game.board.get_cards(GameRules.Side.ENEMY).is_empty()

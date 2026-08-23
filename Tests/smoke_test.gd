extends SceneTree

var game: CardGame
var used_discard := false

func _initialize() -> void:
    run_test()

func run_test() -> void:
    Engine.time_scale = 30.0
    game = load("res://Scenes/Main.tscn").instantiate()
    root.add_child(game)
    await process_frame
    verify_opening()
    verify_mantlet_rule()
    play_first_card()
    verify_reveal()
    for _frame in 2000:
        act_if_needed()
        choose_if_needed()
        if game.finished:
            assert(used_discard)
            quit()
            return
        await process_frame
    push_error("Smoke test did not finish")
    quit(1)

func verify_opening() -> void:
    assert(game.player_hand.get_card_count() == 8)
    assert(game.enemy_hand.get_card_count() == 3)
    assert(game.board.get_cards(GameRules.Side.ENEMY).size() == 1)
    assert(game.board.get_cards(GameRules.Side.ENEMY)[0].face_down)

func verify_mantlet_rule() -> void:
    var archer := CardCatalog.get_data("Archer")
    var mantlet := CardCatalog.get_data("Mantlet")
    assert(game.battle.can_defend(archer, mantlet))

func play_first_card() -> void:
    var card := game.player_hand.get_cards()[0]
    var slot := game.board.get_row_slots(game.board.player_row)[0]
    card.set_hovering(true)
    assert(card.modulate == Color.WHITE)
    card.set_hovering(false)
    game.turns.card_clicked(card)
    assert(slot.targetable)
    slot.set_hovering(true)
    assert(slot.border.modulate == Color("#fee761"))
    slot.set_hovering(false)
    game.turns.target_clicked(slot)
    assert(game.board.get_row_slots(game.board.player_row)[0].get_card() == card)
    slot.set_targetable(true)
    slot.set_hovering(true)
    assert(card.front.modulate == Color("#fee761"))
    slot.set_hovering(false)
    assert(card.front.modulate == Color.WHITE)
    assert(card.position.distance_to(Vector2.ZERO) > 1.0)

func verify_reveal() -> void:
    assert(!game.board.get_cards(GameRules.Side.ENEMY)[0].face_down)

func act_if_needed() -> void:
    if !game.turns.accepting_action:
        return
    var card := game.player_hand.get_cards()[0]
    game.turns.card_clicked(card)
    if game.board.is_full(GameRules.Side.PLAYER) && !used_discard:
        used_discard = true
        game.player_discard.set_hovering(true)
        assert(game.player_discard.border.modulate == Color("#fee761"))
        game.turns.discard_clicked()
    else:
        var slot := game.board.get_row_slots(game.board.player_row)[0]
        game.turns.target_clicked(slot)

func choose_if_needed() -> void:
    if !game.selectable_cards.is_empty():
        game.card_chosen.emit(game.selectable_cards[0])

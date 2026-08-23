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
    assert(game.enemy_hand.get_card_count() == 7)
    assert(game.board.get_cards(GameRules.Side.ENEMY).size() == 1)
    assert(game.board.get_cards(GameRules.Side.ENEMY)[0].face_down)

func verify_mantlet_rule() -> void:
    var archer := CardCatalog.get_data("Archer")
    var mantlet := CardCatalog.get_data("Mantlet")
    assert(game.battle.can_defend(archer, mantlet))

func play_first_card() -> void:
    var card := game.player_hand.get_cards()[0]
    var slot := game.board.get_row_slots(game.board.player_row)[0]
    game.turns.card_dropped(card, slot.global_position)

func verify_reveal() -> void:
    assert(!game.board.get_cards(GameRules.Side.ENEMY)[0].face_down)

func act_if_needed() -> void:
    if !game.turns.accepting_action:
        return
    var card := game.player_hand.get_cards()[0]
    if game.board.is_full(GameRules.Side.PLAYER) && !used_discard:
        used_discard = true
        game.turns.card_dropped(card, game.player_discard.global_position)
    else:
        var slot := game.board.get_row_slots(game.board.player_row)[0]
        game.turns.card_dropped(card, slot.global_position)

func choose_if_needed() -> void:
    if !game.selectable_cards.is_empty():
        game._on_card_selected(game.selectable_cards[0])

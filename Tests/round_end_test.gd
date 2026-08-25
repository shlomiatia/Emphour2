extends SceneTree

var game: CardBattle

func _initialize() -> void:
    run_test()

func run_test() -> void:
    Engine.time_scale = 30.0
    CampaignState.reset()
    CampaignState.player_deck.assign(["Militia"])
    game = load("res://Scenes/Battle/Battle.tscn").instantiate()
    game.enemy_deck.static_cards.assign(["Militia", "Militia", "Militia"])
    game.get_node("Board").slot_count = 1
    root.add_child(game)
    await process_frame
    play_last_card()
    for _frame in 100:
        if game.finished:
            assert(game.enemy_hand.get_card_count() == 2)
            quit()
            return
        await process_frame
    push_error("Last-card battle did not finish")
    quit(1)

func play_last_card() -> void:
    var card := game.player_hand.get_cards()[0]
    var slot := game.board.get_row_slots(game.board.player_row)[0]
    game.turns.card_clicked(card)
    game.turns.target_clicked(slot)

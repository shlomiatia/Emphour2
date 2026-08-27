extends SceneTree

var game: CardBattle

func _initialize() -> void:
    run_test()

func run_test() -> void:
    Engine.time_scale = 30.0
    CampaignState.reset()
    CampaignState.selected_city = CampaignState.act_1_city_id(1)
    CampaignState.player_deck = CampaignState.create_frank_deck(["Militia"])
    game = load("res://Scenes/Battlefield/Battlefield.tscn").instantiate()
    game.get_node("CardSpace/Board").slot_count = 1
    root.add_child(game)
    await game.battle_ready
    var marker := game.battle_hud.marker.position.x
    play_last_card()
    assert(game.battle_hud.preview_tween != null)
    assert(is_equal_approx(game.battle_hud.marker.position.x, marker))
    for _frame in 100:
        if game.finished:
            assert(game.enemy_hand.get_card_count() < 2)
            quit()
            return
        await process_frame
    push_error("Last-card battle did not finish")
    quit(1)

func play_last_card() -> void:
    var card := game.player_hand.get_cards()[0]
    var slot := game.board.get_row_slots(Board.PLAYER_ROW)[0]
    game.turns.card_clicked(card)
    game.turns.target_clicked(slot)
